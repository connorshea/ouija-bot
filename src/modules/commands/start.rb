require 'yaml'

module Bot::DiscordCommands
  # Command for starting a game of Ouija.
  module Start
    extend Discordrb::Commands::CommandContainer

    command(
      :start,
      description: "Starts a new game of Ouija. Takes an optional question argument.",
      usage: "start [question]"
    ) do |event, *question|
      # Only allow this command in a channel named ouija.
      unless event.channel.name == "ouija"
        event.channel.send_temporary_message("This command will only work in a channel named #ouija. Please start a game from there.", 15)
        break
      end

      # Don't allow starting a new question while in the 'delete all' mode.
      settings = Bot::Database::Settings.find_or_create(guild_id: event.server.id)
      break if (settings[:delete_all])

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

    command(
      %i[startwithquestion startq],
      description: "Starts a new game of Ouija with a question chosen from a predetermined list.",
      usage: "startwithquestion"
    ) do |event|
      # Only allow this command in a channel named ouija.
      unless event.channel.name == "ouija"
        event.channel.send_temporary_message("This command will only work in a channel named #ouija. Please start a game from there.", 15)
        break
      end

      # Send a message so we can create a CommandEvent with a message from the bot.
      start_message = event.channel.send_message("Starting a new game of Ouija...")

      questions = YAML.load_file('src/questions.yml')
      questions = questions['questions']
      question = questions.sample
      event.channel.send_message("**Question: #{question}**")

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
        settings.update(current_question: question)
      else
        Bot::Database::Settings.create(guild_id: event.server.id, current_question: question)
      end

      # Delete the starting message because it's no longer necessary.
      start_message.delete
    end
  end
end
