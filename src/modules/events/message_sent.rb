module Bot::DiscordEvents
  # Document your event
  # in some YARD comments here!
  module MessageSent
    extend Discordrb::EventContainer
    message(in: Bot::CONFIG.channel_name) do |event|
      unless message_checks(event.message)
        # Delete the message
        event.message.delete
        # Wait 5 seconds and then delete the warning message.
        event.channel.send_temporary_message('Only one character messages or "Goodbye" are allowed.', 3)
      end

      check_for_successive_messages(event)

      if event.message.content == "Goodbye"
        handle_goodbye(event)
      end
    end

    def self.check_for_successive_messages(event)
      # Check the last two messages in the channel
      last_two_messages = event.channel.history(2)
      # If both messages have the same author, delete the second message
      if last_two_messages[0].author == last_two_messages[1].author
        # TODO: Fix this.
        # Technically this has a bug which allows you to send one letter, then
        # use a command, then send another letter, and be fine.
        if message_checks_inputs(last_two_messages[0]) && message_checks_inputs(last_two_messages[1])
          # Delete the message.
          last_two_messages[0].delete
          # Wait 5 seconds and then delete the warning message.
          event.channel.send_temporary_message("Please don't send two characters in succession, let others participate!", 3)
        end
      end
    end

    def self.handle_goodbye(event)
      goodbye_timestamp = event.timestamp
      goodbye_message_id = event.message.id

      goodbye_string = "Goodbye detected! If you'd like the game to end here, react to the"\
        " Goodbye with :thumbsup:! If two thumbsup aren't given in the next"\
        " 30 seconds, the Goodbye will be deleted."
      goodbye_instructions_message = event.respond(goodbye_string)

      # TODO: Handle this with an Await.
      # message(in: Bot::CONFIG.channel_name) do |event|
      #   unless event.message.author.current_bot?
      #     event.message.delete
      #     event.respond("No new submissions while we deliberate!")
      #   end
      # end

      while (Time.now - goodbye_timestamp < 30)
        puts "Waiting"
        sleep(10)
        puts Time.now - goodbye_timestamp
      end

      @goodbye_success = false
      goodbye_message = event.channel.load_message(goodbye_message_id)
      reacted_with_thumbsup = goodbye_message.reacted_with("👍")

      if reacted_with_thumbsup.length >= 2
        valid_reactions = 0
        reacted_with_thumbsup.each do |reaction|
          unless goodbye_message.author == reaction
            valid_reactions += 1
          end
        end

        if valid_reactions >= 1
          puts "IT'S GOOD!"
          @goodbye_success = true
        end
      end

      if !@goodbye_success
        goodbye_instructions_message.delete
        goodbye_message.delete
        event.channel.send_temporary_message("Not enough :thumbsup:, let's continue!", 5)
      else
        done_message = event.channel.send_message("It is done!")
        completed_message_array = []
        event.channel.history(50).each do |message|
          if message.content.length == 1
            completed_message_array.unshift(message.content.upcase)
          elsif message.content == "Goodbye" && message.id != goodbye_message.id
            break
          end
        end

        event.channel.send_message(completed_message_array.join)
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
  end
end
