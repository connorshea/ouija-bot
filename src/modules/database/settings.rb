module Bot
  module Database
    # Settings
    class Settings < Sequel::Model
      # Log creation
      def after_create
        Discordrb::LOGGER.info("Created settings #{inspect}")
      end
    end
  end
end
