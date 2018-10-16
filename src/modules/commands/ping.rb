module Bot::DiscordCommands
  # Responds with "Pong!".
  # This is used to check if bot is alive
  module Ping
    extend Discordrb::Commands::CommandContainer
    command(:ping, description: "Pings the bot, the bot will return a time in milliseconds to show how long the response took.") do |event|
      # The `respond` method returns a `Message` object, which is stored in a variable `m`. The `edit` method is then called
      # to edit the message with the time difference between when the event was received and after the message was sent.
      m = event.respond('Pong!')
      m.edit "Pong! Time taken: #{(Time.now - event.timestamp) * 1000} ms."
    end
  end
end
