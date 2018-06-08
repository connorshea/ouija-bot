module Bot::DiscordCommands
  # A command for printing meta information about the bot.
  module Info
    extend Discordrb::Commands::CommandContainer

    command(:info, description: "Shows information about the bot.") do |event|
      info = "**Info**\n"\
        "Developer: Connor Shea, aka `connorshea#1180`\n"\
        "Source Code: <https://github.com/connorshea/ouija-bot>\n"\
        "License: MIT"

      event.respond(info)
    end
  end
end
