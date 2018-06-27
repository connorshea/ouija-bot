# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]
### Added
- Add the ability to use `:thumbsdown:` on a Goodbye and have it deleted. ([#15])
- A debug mode, can be toggled with `ouija!enable_debug` and `ouija!disable_debug`. This is only accessible to the owner of the bot right now. It makes it easier to get a "Goodbye" accepted or declined by the bot, only requiring one upvote/downvote. ([#21])

### Changed
- Increase the Goodbye timeout to 5 minutes. ([#15])
- Link to the GitHub commit in the info command's output if the bot is on Heroku.

### Fixed
- Handle the `PinLimitReached` error when a channel reaches 50 pinned messages. ([#20])

## [1.0.0] - 2018-06-19
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
[#15]: https://github.com/connorshea/ouija-bot/pull/15
[#20]: https://github.com/connorshea/ouija-bot/pull/20
[#21]: https://github.com/connorshea/ouija-bot/pull/21

[Unreleased]: https://github.com/connorshea/ouija-bot/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/connorshea/ouija-bot/compare/b00da172b81f63ce4a6a41d17b93ae61e24b96c6...v1.0.0
