# ouija-bot

A Discord bot for playing Ouija.

The bot is built from [z64's gemstone template](https://github.com/z64/gemstone).

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/connorshea/ouija-bot)

## How to play

This bot is for managing games of Ouija. It’s based on [the spirit board “game” of the same name](https://en.wikipedia.org/wiki/Ouija) and the subreddit [r/AskOuija](https://www.reddit.com/r/AskOuija/). 

Essentially, once a game starts each player can submit messages (see below for rules) that are either single characters, `Space`, or `Goodbye`. A `Goodbye` will attempt to end the game. Once the game ends successfully, the bot posts the string of letters/words.

The goal is to collaborate – without talking to each other – and write out a word or phrase.

### Starting a game

You can start a game of Ouija with the command `ouija!start`.

There are two game modes:
- The first, which can be started with `ouija!start`, simply runs the game with no specific topic.
- The second game mode runs the game in the same way, but with a question that the players are attempting to answer. It can be started with `ouija!start Question?`, e.g. `ouija!start Spirits, what is your favorite color?`.

### Allowed messages

Once the game starts, only certain messages are allowed. All other messages will be deleted. 

Only messages that follow these rules will be allowed:
- The message must be one of the following:
	- Only one character long
	- `Space` - These are replaced with a space character in the final string.
	- `Goodbye` - This attempts to end the game.
- Single character messages must be one of the following:
	- Any Latin characters of the alphabet, uppercase or lowercase.
	- Any numbers 0-9.
	- Any punctuation marks, e.g. `?`, `!`, `,`, `’`, `;`, etc.
- The same user cannot send two messages in a row.

### Ending a game with Goodbye

A game of Ouija can be ended when a user sends a `Goodbye`. 

A `Goodbye` causes three things to happen:
- The game stops for up to 5 minutes (600 seconds) and all new messages will be deleted.
- The bot requests that users give two :thumbsup: reactions to the `Goodbye` message. Note that reactions from the user who sent the `Goodbye` will not be counted.
- The bot requests that users give two :thumbsdown: reactions to the `Goodbye` message in order to delete it.

If the game gets to 600 seconds without the `Goodbye` message receiving a sufficient number of reactions, the `Goodbye` message is deleted and the game will continue.

If the `Goodbye` message receives a sufficient number of reactions, the game will end and the bot will post the final answer. The bot checks the number of reactions every 15 seconds, so you shouldn’t need to wait a full 5 minutes for the game to end.

## Bot features

- [x] Delete any messages that aren't either single letters or "Goodbye".
  - [x] This should allow all 26 letters of the alphabet, plus accented characters (e.g. ñ).
  - [x] It should also allow punctuation such as `.`, `?`, `'`, and `!`.
  - [x] Allow spaces via a keyword.
- [x] Delete any messages where the same user adds a letter twice in a row.
- [x] On a "Goodbye" it prints the word you spelled.
- [x] Make it so the "Goodbye" needs two thumbs-up reactions from other users before it will be accepted.
- [x] Pin the message once the game is over.

### Edge-cases

The bot currently doesn't really handle the following:

- Users editing their messages.
- Users deleting their messages.

## Contributing

Pull requests are happily accepted (within reason). See [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

## License

The bot is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT). See [LICENSE](LICENSE).
