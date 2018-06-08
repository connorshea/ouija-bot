module Bot::DiscordEvents
  # Document your event
  # in some YARD comments here!
  module MessageSent
    extend Discordrb::EventContainer
    message(in: Bot::CONFIG.channel_name) do |event|
      unless event.message.content.length == 1 || event.message.author.current_bot? || event.message.content.start_with?(Bot::CONFIG.prefix)
        event.message.delete
        event.respond('ONLY 1 CHARACTER MESSAGES REEEEE')
      end
    end
  end
end
