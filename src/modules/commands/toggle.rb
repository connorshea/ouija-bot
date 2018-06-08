module Bot::DiscordCommands
  # Responds with "Pong!".
  # This used to check if bot is alive
  module Toggle
    extend Discordrb::Commands::CommandContainer

    command(:enable, description: "Enables Ouija mode.") do |event|
      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(enabled: true)
      else
        Bot::Database::Settings.create(guild_id: event.server.id, enabled: true)
      end
      event.respond("Ouija mode is enabled.")
    end

    command(:disable, description: "Disables Ouija mode.") do |event|
      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(enabled: false)
      else
        Bot::Database::Settings.create(guild_id: event.server.id, enabled: false)
      end

      event.respond("Ouija mode is disabled.")
    end
  end
end
