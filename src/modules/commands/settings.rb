module Bot::DiscordCommands
  # Commands for displaying and modifying bot settings.
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
      can_send_messages = event.message.author.permission?(:manage_channels)
      unless can_send_messages
        event.channel.send_temporary_message("You don't have the permissions to do this. Only users who are able to manage channels can enable/disable Ouija mode.", 5)
        break
      end
      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(enabled: true)
      else
        Bot::Database::Settings.create(guild_id: event.server.id, enabled: true)
      end
      event.channel.send_message("Ouija mode is enabled.")
    end

    command(:disable, description: "Disables Ouija mode.") do |event|
      can_send_messages = event.message.author.permission?(:manage_channels)
      unless can_send_messages
        event.channel.send_temporary_message("You don't have the permissions to do this. Only users who are able to manage channels can enable/disable Ouija mode.", 5)
        break
      end
      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(enabled: false)
      else
        Bot::Database::Settings.create(guild_id: event.server.id, enabled: false)
      end

      event.channel.send_message("Ouija mode is disabled.")
    end
  end
end
