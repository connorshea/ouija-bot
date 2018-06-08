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

      # Check the last two messages in the channel
      last_two_messages = event.channel.history(2, before_id: event.message.id)
      # If both messages have the same author, delete the second message
      if last_two_messages[0].author == last_two_messages[1].author
        # TODO: Fix this.
        # Technically this has a bug which allows you to send one letter, then
        # use a command, then send another letter, and be fine.
        if message_checks_inputs(last_two_messages[0]) && message_checks_inputs(last_two_messages[1])
          # Delete the message.
          last_two_messages[1].delete
          # Wait 5 seconds and then delete the warning message.
          event.channel.send_temporary_message("Please don't send two characters in succession, let others participate!", 3)
        end
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
