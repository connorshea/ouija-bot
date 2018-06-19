module Bot::DiscordEvents
  # Document your event
  # in some YARD comments here!
  module MessageSent
    extend Discordrb::EventContainer
    message(in: Bot::CONFIG.channel_name) do |event|
      # Create the settings variable
      settings = Bot::Database::Settings.find_or_create(guild_id: event.server.id)
      # If the `enabled` setting is set to false, return early.
      return unless settings[:enabled]

      # If the message fails the message checks, delete the message and send
      # a warning.
      unless message_checks(event.message)
        # Delete the message
        event.message.delete if event.message
        # Wait 3 seconds and then delete the warning message.
        event.channel.send_temporary_message('Only one character messages or "Goodbye" are allowed.', 3)
      end

      successive_messages = check_for_successive_messages(event)

      if settings[:delete_all] && !event.message.author.current_bot?
        event.channel.send_temporary_message("Delete all mode is enabled.", 5)
        event.message.delete
      end

      # Disable Goodbye handling if delete_all is enabled or if the goodbye is a
      # successive message from the same user.
      disable_goodbye_handling = successive_messages || settings[:delete_all]

      # Handle goodbye if there's a "Goodbye" message and goodbye handling isn't disabled.
      handle_goodbye(event) if event.message.content.capitalize == "Goodbye" && !disable_goodbye_handling
    end

    def self.check_for_successive_messages(event)
      # Check the last five messages before the event message.
      last_five_messages = event.channel.history(5, event.message.id)

      @should_delete_message = false

      # Iterate through the last 5 messages prior to this event.message.
      # We want to iterate through until we either find a message that
      # suggests that the user has submitted a duplicate entry, or until
      # we find a message that suggests the user has not.
      #
      # Technically this only checks the last 5 messages, and therefore
      # it's possible to abuse this limit and just make the bot send 5
      # messages or something, but it's not that important.
      #
      # This loop checks each message for these things in the following order:
      # - If the event message is invalid, break and exit the loop.
      # - If the message is from the bot, ignore it and continue.
      # - If the message is from another user and that message
      #   is a valid submission, exit the loop.
      # - If the message is from the same user but is an invalid submission,
      #   skip to the next message.
      # - If the message is from the same user as the event.message, exit the
      #   loop and set @should_delete_message to true.
      last_five_messages.each do |message|
        # Break unless the event message is valid.
        # If it's not valid, we can break because that means they either used a
        # command or something invalid that will be deleted by the event handler.
        break unless message_checks_inputs(event.message)

        # Skip to the next message if the message is from ouija-bot.
        next if message.author.current_bot?

        # If the author of the event message and the current message are not
        # the same, check if the message from another user is a valid submission.
        # If it is, we can break. If not, we have to continue.
        break if event.message.author != message.author && message_checks_inputs(message)

        # If the author of the event message and the current message are the same,
        # but the current message is invalid, skip to the next message.
        next if event.message.author == message.author && !message_checks_inputs(message)

        # Break if Goodbye. This suggests a new game started.
        break if message.content.capitalize == "Goodbye"

        # Check if the author of this message is the same as the author of
        # the event.message.
        if event.message.author == message.author
          @should_delete_message = true
          break
        end
      end

      if @should_delete_message
        # Delete the message.
        event.message.delete
        # Wait 3 seconds and then delete the warning message.
        event.channel.send_temporary_message("Please don't send two characters in succession, let others participate!", 3)
      end

      return @should_delete_message
    end

    def self.handle_goodbye(event)
      goodbye_timestamp = event.timestamp
      goodbye_message_id = event.message.id

      goodbye_string = "**Goodbye detected!** If you'd like the game to end"\
        " here, react to the Goodbye with :thumbsup:! If two thumbsup"\
        " (excluding the person who sent Goodbye) aren't given in the next"\
        " 120 seconds, the Goodbye will be deleted."
      goodbye_instructions_message = event.respond(goodbye_string)

      enable_delete_all(event)

      @goodbye_success = false

      while Time.now - goodbye_timestamp < 120
        sleep(15)
        @goodbye_success = goodbye_check_helper(event, goodbye_message_id)
        break if @goodbye_success
      end

      if @goodbye_success
        completed_message_array = []
        # Run through all the messages before the most recent Goodbye, until the last game's goodbye.
        event.channel.history(100, goodbye_instructions_message.id).each_with_index do |message, index|
          if message_checks_limit_characters(message)
            completed_message_array.unshift(message.content)
          elsif (message.content.capitalize == "Goodbye" || message.content.start_with?("Game over!")) && message.id != goodbye_message_id
            break
          # We can only search through the last 100 messages, index 99 is the 100th item.
          # If no end message is found, just print whatever we have from the last 100 messages.
          elsif index == 99
            break
          end
        end

        disable_delete_all(event)
        goodbye_instructions_message.delete
        game_over_message = event.channel.send_message("Game over! Ouija Says **#{completed_message_array.join.upcase}**")
        game_over_message.pin
      else
        goodbye_instructions_message.delete
        goodbye_message = event.channel.load_message(goodbye_message_id)
        # Just in case the Goodbye message was deleted before this, check for its existence first.
        goodbye_message.delete if goodbye_message
        event.channel.send_temporary_message("Not enough :thumbsup:, let's continue!", 15)
        disable_delete_all(event)
      end
    end

    def self.goodbye_check_helper(event, goodbye_message_id)
      goodbye_success = false

      begin
        goodbye_message = event.channel.load_message(goodbye_message_id)
        reacted_with_thumbsup = goodbye_message.reacted_with("👍")

        if reacted_with_thumbsup.length >= 2
          valid_reactions = 0
          reacted_with_thumbsup.each do |reaction|
            valid_reactions += 1 unless goodbye_message.author == reaction
          end

          goodbye_success = true if valid_reactions >= 2
        end
      rescue NoMethodError => e
        puts e
      end

      return goodbye_success
    end

    # Returns true if the message is any of the following:
    # - 1 character long and a letter/digit/punctuation mark.
    # - "Goodbye" / "goodbye"
    # - from the current bot
    # - is a bot command
    def self.message_checks(msg)
      return (
        message_checks_limit_characters(msg) ||
        msg.content.capitalize == "Goodbye" ||
        msg.author.current_bot? ||
        msg.content.start_with?(Bot::CONFIG.prefix)
      )
    end

    # Returns true if the message is either 1 character long and within
    # the valid character set, or "Goodbye".
    # This is used to validate that messages are only one entry.
    def self.message_checks_inputs(msg)
      return (
        message_checks_limit_characters(msg) ||
        msg.content.capitalize == "Goodbye"
      )
    end

    # Returns true if the message is 1 character long and within
    # the valid character set.
    def self.message_checks_limit_characters(msg)
      # Matches the message to make sure it's:
      # - Only one character
      # - Either letters, numbers, or punctuation.
      return msg.content.match?(/^([[:alnum:]]|[[:punct:]]){1}$/)
    end

    def self.enable_delete_all(event)
      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(delete_all: true)
      else
        Bot::Database::Settings.create(guild_id: event.server.id, delete_all: true)
      end
      event.send_temporary_message("Delete all mode is enabled.", 5)
    end

    def self.disable_delete_all(event)
      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(delete_all: false)
      else
        Bot::Database::Settings.create(guild_id: event.server.id, delete_all: false)
      end
      event.send_temporary_message("Delete all mode is disabled.", 5)
    end
  end
end
