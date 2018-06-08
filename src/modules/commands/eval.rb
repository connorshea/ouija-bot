module Bot::DiscordCommands
  # Command for evaluating Ruby code in an active bot.
  # Only the `event.user` with matching discord ID of `CONFIG.owner`
  # can use this command.
  # rubocop:disable Security/Eval, Style/RescueStandardError
  module Eval
    extend Discordrb::Commands::CommandContainer
    command(:eval, help_available: false) do |event, *code|
      break unless event.user.id == Bot::CONFIG.owner
      begin
        eval code.join(' ')
      rescue => e
        "An error occurred 😞 ```#{e}```"
      end
    end
  end
  # rubocop:enable Security/Eval, Style/RescueStandardError
end
