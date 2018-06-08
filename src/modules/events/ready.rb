module Bot::DiscordEvents
  # This event is processed each time the bot successfully connects to Discord.
  module Ready
    extend Discordrb::EventContainer
    ready do |event|
      event.bot.game = Bot::CONFIG.game
    end
  end
end
