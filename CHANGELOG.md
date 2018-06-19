# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- Delete any messages that aren't either single letters or "Goodbye".
- "Goodbye" handling.
- Keep settings in a Postgres database.
- Delete any messages where the same user posts submissions successively. ([#6])
- A special "Space" keyword. ([#13])
- `ouija!info` command that prints info about the bot.
- `ouija!howtoplay` command that prints a link to the How to Play section in the `README.md`.
- `ouija!start` command that starts a new game. ([#14])
- Use Rubocop for style linting.
- Pin the final message once a game ends.

[#6]: https://github.com/connorshea/ouija-bot/pull/6
[#13]: https://github.com/connorshea/ouija-bot/pull/13
[#14]: https://github.com/connorshea/ouija-bot/pull/14

[Unreleased]: https://github.com/connorshea/ouija-bot/compare/b00da172b81f63ce4a6a41d17b93ae61e24b96c6...HEAD
