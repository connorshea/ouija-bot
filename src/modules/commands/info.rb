module Bot::DiscordCommands
  # A command for printing meta information about the bot.
  module Info
    extend Discordrb::Commands::CommandContainer

    command(:info, description: "Shows information about the bot.") do |event|
      info = "**Info**\n"\
        "Developer: Connor Shea, aka `connorshea#4056`\n"\
        "Source Code: <https://github.com/connorshea/ouija-bot>\n"\
        "License: MIT"

      info << "\nVersion: <https://github.com/connorshea/ouija-bot/commit/#{ENV['HEROKU_SLUG_COMMIT']}>" if ENV['HEROKU_SLUG_COMMIT']

      event.respond(info)
    end
  end
end
