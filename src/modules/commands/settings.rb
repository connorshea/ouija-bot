module Bot::DiscordCommands
  # Commands for displaying and modifying bot settings.
  module Settings
    extend Discordrb::Commands::CommandContainer

    command(:settings, description: "Shows settings info.") do |event|
      settings = Bot::Database::Settings.find_or_create(guild_id: event.server.id)

      settings_info = "**Settings**\n"\
        "`Ouija Mode`: #{settings[:enabled] ? 'Enabled' : 'Disabled'}\n"\
        "`Delete All Mode`: #{settings[:delete_all] ? 'Enabled' : 'Disabled'}\n"\
        "`Current Question`: #{settings[:current_question]}\n"\
        "`Archive Mode`: #{settings[:archive] ? 'Enabled' : 'Disabled'}\n"\
        "`Debug Mode`: #{settings[:debug_mode] ? 'Enabled' : 'Disabled'}\n"
      event.respond(settings_info)
    end

    command(:enable, description: "Enables Ouija mode. Only available for users with the ability to manage channels.") do |event|
      # Only allow this command if the user that triggered the event can manage
      # channels in this server or if the event was triggered by the bot (this
      # implies that the command was triggered internally by the
      # `execute_command` method).
      can_send_messages = event.user.permission?(:manage_channels)
      unless can_send_messages || event.user.current_bot?
        event.channel.send_temporary_message("You don't have the permissions to do this. Only users who are able to manage channels can enable/disable Ouija mode.", 5)
        break
      end

      # Set `enabled` to true.
      # If there's no row in the database for this server, create one.
      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(enabled: true)
      else
        Bot::Database::Settings.create(guild_id: event.server.id, enabled: true)
      end

      event.channel.send_message("Ouija mode is enabled.")
    end

    command(:enable_archive, description: "Enables Archive mode. Only available for users with the ability to manage channels.") do |event|
      # Only allow this command if the user that triggered the event can manage
      # channels in this server.
      unless event.user.permission?(:manage_channels)
        event.channel.send_temporary_message("You don't have the permissions to do this. Only users who are able to manage channels can enable/disable Archive mode.", 5)
        break
      end

      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(archive: true)
      else
        Bot::Database::Settings.create(guild_id: event.server.id, archive: true)
      end

      event.channel.send_message("Archive mode is enabled.")
    end

    command(:disable_archive, description: "Disables Archive mode. Only available for users with the ability to manage channels.") do |event|
      # Only allow this command if the user that triggered the event can manage
      # channels in this server.
      unless event.user.permission?(:manage_channels)
        event.channel.send_temporary_message("You don't have the permissions to do this. Only users who are able to manage channels can enable/disable Archive mode.", 5)
        break
      end

      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(archive: false)
      else
        Bot::Database::Settings.create(guild_id: event.server.id, archive: false)
      end

      event.channel.send_message("Archive mode is disabled.")
    end

    command(:disable, description: "Disables Ouija mode. Only available for users with the ability to manage channels.") do |event|
      # Only allow this command if the user that triggered the event can manage
      # channels in this server or if the event was triggered by the bot (this
      # implies that the command was triggered internally by the
      # `execute_command` method).
      can_send_messages = event.user.permission?(:manage_channels)
      unless can_send_messages || event.user.current_bot?
        event.channel.send_temporary_message("You don't have the permissions to do this. Only users who are able to manage channels can enable/disable Ouija mode.", 5)
        break
      end

      # Set `enabled` to false.
      # If there's no row in the database for this server, create one.
      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(enabled: false)
      else
        Bot::Database::Settings.create(guild_id: event.server.id, enabled: false)
      end

      event.channel.send_message("Ouija mode is disabled.")
    end

    command(:enable_debug, help_available: false, description: "Enables a debug mode.") do |event|
      break unless event.user.id == Bot::CONFIG.owner

      # Set `enabled` to true.
      # If there's no row in the database for this server, create one.
      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(debug_mode: true)
      else
        Bot::Database::Settings.create(guild_id: event.server.id, debug_mode: true)
      end

      event.channel.send_message("Debug mode is enabled.")
    end

    command(:disable_debug, help_available: false, description: "Disables a debug mode.") do |event|
      break unless event.user.id == Bot::CONFIG.owner

      # Set `enabled` to false.
      # If there's no row in the database for this server, create one.
      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(debug_mode: false)
      else
        Bot::Database::Settings.create(guild_id: event.server.id, debug_mode: false)
      end

      event.channel.send_message("Debug mode is disabled.")
    end
  end
end
