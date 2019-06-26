module Bot::DiscordEvents
  # Document your event
  # in some YARD comments here!
  module MessageSent
    extend Discordrb::EventContainer
    message(in: Bot::CONFIG.channel_name) do |event|
      # Create the settings variable
      settings = Bot::Database::Settings.find_or_create(guild_id: event.server.id)
      # If the `enabled` setting is set to false, break out of this block early.
      next unless settings[:enabled]

      # If the message fails the message checks, delete the message and send
      # a warning.
      unless message_checks(event.message)
        # Delete the message
        event.message.delete if event.message
        # Wait 3 seconds and then delete the warning message.
        event.channel.send_temporary_message('Only one character messages, "Space", or "Goodbye" are allowed.', 3)
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
      # - If the message starts with ouija!start, break and exit the loop.
      # - If the event message is invalid, break and exit the loop.
      # - If the message is from the bot, ignore it and continue.
      # - If the message is from another user and that message
      #   is a valid submission, exit the loop.
      # - If the message is from the same user but is an invalid submission,
      #   skip to the next message.
      # - If the message is Goodbye, break and exit the loop.
      # - If the message is from the same user as the event.message, exit the
      #   loop and set @should_delete_message to true.
      last_five_messages.each do |message|
        # Break if there's a `ouija!start` command. This suggests a new game started.
        break if message.content.start_with?("#{Bot::CONFIG.prefix}start")

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
      settings = Bot::Database::Settings.find_or_create(guild_id: event.server.id)

      goodbye_string = "**Goodbye detected!** If you'd like the game to end"\
        " here, react to the Goodbye with :thumbsup:! If two thumbsup"\
        " (excluding the bot and the user who sent the Goodbye) aren't"\
        " given in the next 10 minutes, the Goodbye will be deleted.\n"\
        "If you want to delete the Goodbye without waiting the full 10"\
        " minutes, react to the Goodbye with :thumbsdown:. Two thumbsdown"\
        " (excluding the bot) will cause the Goodbye to be deleted so the"\
        " game can continue."

      goodbye_string = "**Debug mode is enabled**, only one upvote/downvote required for success." if settings[:debug_mode]
      goodbye_instructions_message = event.respond(goodbye_string)

      # Avoid hitting the rate-limit.
      sleep(2)

      # Add a thumbsup and thumbsdown to the Goodbye message.
      goodbye_message = event.channel.load_message(goodbye_message_id)

      # Unicode character for thumbsup emoji
      goodbye_message.react("\u{1F44D}")

      # Unicode character for thumbsdown emoji
      goodbye_message.react("\u{1F44E}")

      enable_delete_all(event)

      @goodbye_success = false
      @goodbye_failure = false

      # Loop and keep checking for goodbye failure/success until 10
      # minutes have passed.
      while Time.now - goodbye_timestamp < 600
        # Run the check every 5 seconds if debug mode is on.
        # Otherwise only run it every 15.
        settings[:debug_mode] ? sleep(5) : sleep(15)
        @goodbye_success = goodbye_success_check_helper(event, goodbye_message_id)
        @goodbye_failure = goodbye_failure_check_helper(event, goodbye_message_id)
        break if @goodbye_success || @goodbye_failure
      end

      if @goodbye_success
        completed_message_array = []
        # Run through all the messages before the most recent Goodbye, until the last game's goodbye.
        event.channel.history(100, goodbye_instructions_message.id).each_with_index do |message, index|
          if message_checks_limit_characters(message)
            completed_message_array.unshift(message.content)
          elsif message.content.capitalize == "Space"
            completed_message_array.unshift(" ")
          elsif (message.content.capitalize == "Goodbye" || message.content.start_with?("Game over!") || message.content.start_with?("#{Bot::CONFIG.prefix}start")) && message.id != goodbye_message_id
            break
          # We can only search through the last 100 messages, index 99 is the 100th item.
          # If no end message is found, just print whatever we have from the last 100 messages.
          elsif index == 99
            break
          end
        end

        disable_delete_all(event)

        goodbye_instructions_message.delete

        settings = Bot::Database::Settings.find_or_create(guild_id: event.server.id)
        first_line = "Game over! "
        first_line << "Question: **#{settings[:current_question]}**\n" if settings[:current_question].chomp(" ") != ""
        game_over_message = event.channel.send_message(
          "#{first_line}"\
          "Ouija says **#{completed_message_array.join.upcase}**"
        )

        begin
          # Either pin the final game result or post it in a #ouija-archives channel.
          handle_game_over_message(event, game_over_message)
        rescue Discordrb::Errors::NoPermission => e
          # Catch a permissions error and send a message about the problem.
          error = settings[:archive] == true ? "post in #ouija-archives." : "pin the message."
          event.channel.send_message("Insufficient permissions, unable to #{error}")
          puts "ERROR: #{e.inspect}"
        end

        # Disable the bot.
        command_event = Discordrb::Commands::CommandEvent.new(game_over_message, event.bot)
        event.bot.execute_command(:disable, command_event, [])
      elsif @goodbye_failure
        goodbye_instructions_message.delete
        goodbye_message = event.channel.load_message(goodbye_message_id)
        # Just in case the Goodbye message was deleted before this, check for its existence first.
        goodbye_message.delete if goodbye_message
        event.channel.send_temporary_message("Recieved more than two :thumbsdown:, let's continue!", 15)
        disable_delete_all(event)
      else
        goodbye_instructions_message.delete
        goodbye_message = event.channel.load_message(goodbye_message_id)
        # Just in case the Goodbye message was deleted before this, check for its existence first.
        goodbye_message.delete if goodbye_message
        event.channel.send_temporary_message("Not enough :thumbsup:, let's continue!", 15)
        disable_delete_all(event)
      end
    end

    def self.goodbye_success_check_helper(event, goodbye_message_id)
      goodbye_success = false
      settings = Bot::Database::Settings.find_or_create(guild_id: event.server.id)

      begin
        goodbye_message = event.channel.load_message(goodbye_message_id)
        reacted_with_thumbsup = goodbye_message.reacted_with("👍")

        number_of_reactions_needed = 2
        number_of_reactions_needed = 1 if settings[:debug_mode]

        if reacted_with_thumbsup.length >= number_of_reactions_needed
          valid_reactions = 0
          reacted_with_thumbsup.each do |reaction|
            # It's a valid reaction unless the Goodbye message author
            # was the one who sent it, or if the bot is in debug mode.
            # It's never a valid reaction if the bot made the reaction.
            valid_reactions += 1 if (goodbye_message.author != reaction || settings[:debug_mode]) && !reaction.current_bot?
          end

          goodbye_success = true if valid_reactions >= number_of_reactions_needed
        end
      rescue NoMethodError => e
        puts e
      end

      return goodbye_success
    end

    # Checks if there have been two or more thumbsdown on a Goodbye, which will cancel it.
    def self.goodbye_failure_check_helper(event, goodbye_message_id)
      goodbye_failure = false
      settings = Bot::Database::Settings.find_or_create(guild_id: event.server.id)

      # This number includes the default bot thumbsup for simplicity's sake.
      number_of_reactions_needed = 3
      number_of_reactions_needed = 2 if settings[:debug_mode]

      begin
        goodbye_message = event.channel.load_message(goodbye_message_id)
        reacted_with_thumbsdown = goodbye_message.reacted_with("👎")
        goodbye_failure = true if reacted_with_thumbsdown.length >= number_of_reactions_needed
      rescue NoMethodError => e
        puts e
      end

      return goodbye_failure
    end

    # Returns true if the message is any of the following:
    # - 1 character long and a letter/digit/punctuation mark.
    # - "Goodbye" / "goodbye"
    # - "Space" / "space"
    # - from the current bot
    # - is a bot command
    def self.message_checks(msg)
      config_prefix_check = false
      config_prefix_check = msg.content.start_with?(Bot::CONFIG.prefix) unless Bot::CONFIG.prefix.nil?

      return (
        message_checks_limit_characters(msg) ||
        msg.content.capitalize == "Goodbye" ||
        msg.content.capitalize == "Space" ||
        msg.author.current_bot? ||
        config_prefix_check
      )
    end

    # Returns true if the message is either 1 character long and within
    # the valid character set, "Space", or "Goodbye".
    # This is used to validate that messages are only one entry.
    def self.message_checks_inputs(msg)
      return (
        message_checks_limit_characters(msg) ||
        msg.content.capitalize == "Goodbye" ||
        msg.content.capitalize == "Space"
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

    # Enables Delete All mode.
    def self.enable_delete_all(event)
      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(delete_all: true)
      else
        Bot::Database::Settings.create(guild_id: event.server.id, delete_all: true)
      end
      event.send_temporary_message("Delete all mode is enabled.", 5)
    end

    # Disables Delete All mode.
    def self.disable_delete_all(event)
      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(delete_all: false)
      else
        Bot::Database::Settings.create(guild_id: event.server.id, delete_all: false)
      end
      event.send_temporary_message("Delete all mode is disabled.", 5)
    end

    def self.handle_game_over_message(event, game_over_message)
      settings = Bot::Database::Settings.find(guild_id: event.server.id)

      if settings[:archive] == false
        # Pin the goodbye message or handle the error if one occurs.
        begin
          game_over_message.pin
        rescue RestClient::BadRequest => ex
          data = JSON.parse(ex.response.body)
          if Discordrb::Errors.error_class_for(data['code']) == Discordrb::Errors::PinLimitReached
            event.channel.send_message(
              "Pin limit reached (only 50 are allowed per channel), we can't pin"\
                " this message! Please create a new Ouija channel or unpin some of the"\
                " existing messages. Alternatively, you can enable Archive mode so the"\
                " bot will post the final message in an archives channel instead."
            )
          end
        end
      elsif settings[:archive] == true
        archives_channel = event.server.text_channels.find { |channel| channel.name == "ouija-archives" }

        event.channel.send_message("There's no channel named `ouija-archives`, please create one in order for Archive mode to work.") if archives_channel.nil?

        game_over_message_link = "https://discordapp.com/channels/#{event.server.id}/#{game_over_message.channel.id}/#{game_over_message.id}"

        unless archives_channel.nil?
          archives_channel.send_message(
            "Link: #{game_over_message_link}\n"\
              "#{game_over_message.text.gsub(/^Game over!\ /, '')}"
          )
        end
      end
    end
  end
end
