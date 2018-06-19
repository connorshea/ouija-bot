module Bot::DiscordCommands
  # A command for printing a link to the 'How to Play' guide.
  module HowToPlay
    extend Discordrb::Commands::CommandContainer

    command(:howtoplay, description: "Provides a link to the 'How to Play' guide.") do |event|
      event.respond("How to Play: <https://github.com/connorshea/ouija-bot#how-to-play>")
    end
  end
end
