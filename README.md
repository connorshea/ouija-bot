# ouija-bot
A Discord bot based on the subreddit [r/AskOuija](https://www.reddit.com/r/AskOuija/).

TL;DR The bot will randomly open a Discord channel, e.g. #ouija. It will post an explanation message of how the game is played and then one random letter of the alphabet. The goal is for users to write out a word or phrase one letter at a time.

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
