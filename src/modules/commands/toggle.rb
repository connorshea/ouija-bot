module Bot::DiscordCommands
  # Responds with "Pong!".
  # This used to check if bot is alive
  module Toggle
    extend Discordrb::Commands::CommandContainer

    command(:enable, description: "Enables Ouija mode.") do |event|
      Bot::Database::Settings.enabled = true
      event.respond("Ouija mode is enabled.")
    end

    command(:disable, description: "Disables Ouija mode.") do |event|
      Bot::Database::Settings.enabled = false
      event.respond("Ouija mode is disabled.")
    end
  end
end
