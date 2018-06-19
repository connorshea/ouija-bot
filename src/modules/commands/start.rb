module Bot::DiscordCommands
  # Command for starting a game of Ouija.
  module Start
    extend Discordrb::Commands::CommandContainer

    command(
      :start,
      description: "Starts a new game of Ouija. Takes an optional question argument.",
      usage: "start [question]",
      channels: ['ouija']
    ) do |event, *question|
      # Send a message so we can create a CommandEvent with a message from the bot.
      start_message = event.channel.send_message("Starting a new game of Ouija...")
      # Create a CommandEvent with a message sent by the bot.
      # This is necessary because the `enable` command only works if the user
      # is either able to manage channels or if it's triggered by the bot.
      # The only time the bot triggers the command is when doing it internally
      # like this.
      command_event = Discordrb::Commands::CommandEvent.new(start_message, event.bot)
      # Execute the `enable` command to start a new game of Ouija.
      event.bot.execute_command(:enable, command_event, [])

      # Set the `current_question` value for this server.
      # If there's no row in the database for this server, create one.
      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(current_question: question.join(' '))
      else
        Bot::Database::Settings.create(guild_id: event.server.id, current_question: question.join(' '))
      end

      # Delete the starting message because it's no longer necessary.
      start_message.delete
    end
  end
end
