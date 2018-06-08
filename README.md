# ouija-bot
A Discord bot based on the subreddit [r/AskOuija](https://www.reddit.com/r/AskOuija/).

TL;DR The bot will randomly open a Discord channel, e.g. `#ouija`. It will post an explanation message of how the game is played and then one random letter of the alphabet. The goal is for users to write out a word or phrase one letter at a time.

The bot is based on [z64's gemstone template](https://github.com/z64/gemstone).

### Bot Duties

- Unlock a Discord channel.
- Delete any messages that aren't either single letters or "Goodbye".
  - This should allow all 26 letters of the alphabet, plus accented characters (e.g. ñ).
  - No spaces?
  - It should also allow punctuation such as `.`, `?`, `'`, and `!`.
- Delete any messages where the same user adds a letter twice in a row.
- On a "Goodbye" it prints the word you spelled and locks the channel for a few hours.
- It will randomly come back after somewhere between 2 and 6 hours.
  - Make this configurable?
- Make it so the "Goodbye" needs two thumbs-up reactions from other users before it will be accepted.

### Edge-cases

- Users editing their messages.
- Users deleting their messages.
- Posting images/files to the channel.
  - This can be solved by preventing file upload in the channel?

### Extras

- Make it possible for mods/admins to run the bot with a command which unlocks the channel and starts another round of Ouija?
- Pinging to make sure the bot is online.
- Safeguard to handle a case where the bot disconnects in the middle of a game?
- Make an "AskOuija" mode where someone submits a question to the bot.
  - This can be done in one of two ways:
    - Have the bot start by asking for a question submission.
    - Have the bot accept suggestions in another channel like `#bot-spam` and then post a message with a list of the questions. It then has people react to that message with number emoji and chooses the top-voted question.

## Development

To start, you'll need Ruby and Postgres.

- `gem install bundler`
- `bundle install` to install dependencies
- Create a `.env` file and add an environmental variable called `DISCORD_TOKEN`.

The `.env` file should look like this:

```
# Replace the random string of characters with your token (yes I invalidated this token, don't worry).
DISCORD_TOKEN=NDU0NDA3Mzk2MzQxODQxOTY3.DftMXw.Scfd1sM2rEGWNSnbOquqcWmmnxY
# Replace the ID number with the client ID for your instance of the Discord bot.
DISCORD_CLIENT_ID=454407396341841967
```

- Enter the postgres CLI with `psql` and run `CREATE DATABASE ouijabot;`, this should create the database.
- `rake` will start the bot and allow it to be interacted-with.
