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

      unless message_checks(event.message)
        # Delete the message
        event.message.delete
        # Wait 3 seconds and then delete the warning message.
        event.channel.send_temporary_message('Only one character messages or "Goodbye" are allowed.', 3)
      end

      check_for_successive_messages(event)

      if settings[:delete_all] && !event.message.author.current_bot?
        event.channel.send_temporary_message("Delete all is enabled", 5)
        event.message.delete
      end

      handle_goodbye(event) if event.message.content == "Goodbye"
    end

    def self.check_for_successive_messages(event)
      # Check the last two messages in the channel
      last_two_messages = event.channel.history(2)
      # Exit unless both messages have the same author.
      return unless last_two_messages[0].author == last_two_messages[1].author

      # TODO: Fix this.
      # Technically this has a bug which allows you to send one letter, then
      # use a command, then send another letter, and be fine.
      return unless message_checks_inputs(last_two_messages[0]) && message_checks_inputs(last_two_messages[1])

      # Delete the message.
      last_two_messages[0].delete
      # Wait 3 seconds and then delete the warning message.
      event.channel.send_temporary_message("Please don't send two characters in succession, let others participate!", 3)
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

      while Time.now - goodbye_timestamp < 120
        # puts "Waiting"
        sleep(15)
        # puts Time.now - goodbye_timestamp
      end

      @goodbye_success = false
      begin
        goodbye_message = event.channel.load_message(goodbye_message_id)
        reacted_with_thumbsup = goodbye_message.reacted_with("👍")

        if reacted_with_thumbsup.length >= 2
          valid_reactions = 0
          reacted_with_thumbsup.each do |reaction|
            valid_reactions += 1 unless goodbye_message.author == reaction
          end

          @goodbye_success = true if valid_reactions >= 2
        end
      rescue NoMethodError => e
        puts e
      end

      if @goodbye_success
        completed_message_array = []
        # Run through all the messages before the most recent Goodbye, until the last game's goodbye.
        event.channel.history(100, goodbye_instructions_message.id).each_with_index do |message, index|
          if message.content.length == 1
            completed_message_array.unshift(message.content)
          elsif (message.content == "Goodbye" || message.content.start_with?("Game over!")) && message.id != goodbye_message.id
            break
          # We can only search through the last 100 messages, index 99 is the 100th item.
          # If no end message is found, just print whatever we have from the last 100 messages.
          elsif index == 99
            break
          end
        end

        disable_delete_all(event)
        goodbye_instructions_message.delete
        event.channel.send_message("Game over! Ouija Says #{completed_message_array.join.upcase}")
      else
        goodbye_instructions_message.delete
        # Just in case the Goodbye message was deleted before this, check for its existence first.
        goodbye_message.delete if goodbye_message
        event.channel.send_temporary_message("Not enough :thumbsup:, let's continue!", 15)
        disable_delete_all(event)
      end
    end

    # Returns true if the message is any of the following:
    # - 1 character long
    # - "Goodbye"
    # - from the current bot
    # - is a bot command
    def self.message_checks(msg)
      return (
        msg.content.length == 1 ||
        msg.content == "Goodbye" ||
        msg.author.current_bot? ||
        msg.content.start_with?(Bot::CONFIG.prefix)
      )
    end

    # Returns true if the message is either 1 character long or "Goodbye".
    # This is used to validate that messages are only one entry.
    def self.message_checks_inputs(msg)
      return (
        msg.content.length == 1 ||
        msg.content == "Goodbye"
      )
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
