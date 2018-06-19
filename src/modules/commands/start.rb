module Bot::DiscordCommands
  # Command for starting a game of Ouija.
  module Start
    extend Discordrb::Commands::CommandContainer

    command(:start, description: "Starts a new game of Ouija. Takes an optional question argument.") do |event, *question|
      start_message = event.channel.send_message("Starting a new game of Ouija...")
      command_event = Discordrb::Commands::CommandEvent.new(start_message, event.bot)
      event.bot.execute_command(:enable, command_event, [])

      settings = Bot::Database::Settings.find(guild_id: event.server.id)
      if settings
        settings.update(current_question: question.join(' '))
      else
        Bot::Database::Settings.create(guild_id: event.server.id, current_question: question.join(' '))
      end

      start_message.delete
    end
  end
end
