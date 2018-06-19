# ouija-bot
A Discord bot based on the subreddit [r/AskOuija](https://www.reddit.com/r/AskOuija/).

TL;DR The bot will randomly open a Discord channel, e.g. `#ouija`. It will post an explanation message of how the game is played and then one random letter of the alphabet. The goal is for users to write out a word or phrase one letter at a time.

The bot is based on [z64's gemstone template](https://github.com/z64/gemstone).

### Bot Duties

- [x] Delete any messages that aren't either single letters or "Goodbye".
  - [x] This should allow all 26 letters of the alphabet, plus accented characters (e.g. ñ).
  - [x] It should also allow punctuation such as `.`, `?`, `'`, and `!`.
  - [x] Allow spaces via a keyword.
- [x] Delete any messages where the same user adds a letter twice in a row.
- [x] On a "Goodbye" it prints the word you spelled.
- [x] Make it so the "Goodbye" needs two thumbs-up reactions from other users before it will be accepted.
- [x] Pin the message once the game is over.

### Edge-cases

- Users editing their messages.
- Users deleting their messages.
- Posting images/files to the channel.

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
- Create a `.env` file and add environmental variables called `DISCORD_TOKEN` and `DISCORD_CLIENT_ID`.

The `.env` file should look like this:

```
# Replace the random string of characters with your token (yes I invalidated this token, don't worry).
DISCORD_TOKEN=NDU0NDA3Mzk2MzQxODQxOTY3.DftMXw.Scfd1sM2rEGWNSnbOquqcWmmnxY
# Replace the ID number with the client ID for your instance of the Discord bot.
DISCORD_CLIENT_ID=454407396341841967
```

- Enter the postgres CLI with `psql` and run `CREATE DATABASE ouijabot;`, this should create the database.
- `rake` will start the bot and allow it to be interacted-with.

## Deployment

This is meant to be deployed on Heroku, it should probably work elsewhere but
these steps are specific to Heroku.

- Fork this repository
- In `data/config.yaml` you'll need to change the owner to your own Discord User ID. This can be accessed by enabling Developer Mode in the Discord Settings, then right-clicking on your username and using "Copy ID".
- Create a new application at https://discordapp.com/developers/applications/me, give it a name and also, optionally, a description and profile picture.
- After creating the app, Discord will show you the app's page which has some configuration options. You'll want to make note of the "Client ID". It'll be important for later.
- Use "Create a Bot User" to enable the bot.
- Click to reveal the token and copy it.
- Create a new Heroku app.
- On the Deploy page, connect the forked GitHub repository to the Heroku app.
- In Settings, add two "Config Vars":
  - `DISCORD_CLIENT_ID`, which should be set to the Discord bot app's client ID that was mentioned earlier.
  - `DISCORD_TOKEN`, which should be set to the token, also mentioned earlier.
- On the "Resources" page, add the Heroku Postgres addon.
- Deploy the bot from the "Deploy" page.
- On the "Resources" page, enable the `worker bundle exec rake` dyno.
- Back to the Discord app page, click "Generate Oauth2 URL" button.
- Enable the following permissions: "Send Messages", "Manage Messages", "Read Message History".
- Copy the link, this link can be used to add bots to a server. You can use it yourself if you have permissions to add bots, or you can give it to the moderators of a server for them to add it.
