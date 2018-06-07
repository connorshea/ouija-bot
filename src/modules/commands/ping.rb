module Bot::DiscordCommands
  # Responds with "Pong!".
  # This used to check if bot is alive
  module Ping
    extend Discordrb::Commands::CommandContainer
    command(:ping, description: "Pings the bot, the bot will return a time in milliseconds to show how long the response took.") do |_event|
      # The `respond` method returns a `Message` object, which is stored in a variable `m`. The `edit` method is then called
      # to edit the message with the time difference between when the event was received and after the message was sent.
      m = _event.respond('Pong!')
      m.edit "Pong! Time taken: #{(Time.now - _event.timestamp) * 1000} ms."
    end
  end
end
