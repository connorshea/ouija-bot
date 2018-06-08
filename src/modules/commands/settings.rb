module Bot::DiscordCommands
  module Settings
    extend Discordrb::Commands::CommandContainer

    command(:settings, description: "Shows settings info.") do |event|
      settings = Bot::Database::Settings.find_or_create(guild_id: event.server.id)

      settings_info = "**Settings**\n"\
        "`Ouija Mode`: #{settings[:enabled] ? 'Enabled' : 'Disabled'}\n"\
        "`Delete All Mode`: #{settings[:delete_all] ? 'Enabled' : 'Disabled'}"
      event.respond(settings_info)
    end

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
