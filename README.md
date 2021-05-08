# [BanFromDiscord](https://github.com/pollovolante/BanFromDiscord)

banhammerbanhammerbanhammerbanhammerbanhammer



# Setup

Clone the repository with `git clone https://github.com/pollovolante/BanFromDiscord` or download and extract the zip file.


## Installation

**Note: You need [NodeJS](https://nodejs.org) installed on your system.**

Install dependencies by running `npm i` in your terminal.


## Discord Bot

Follow this guide [here](https://discordjs.guide/preparations/setting-up-a-bot-application.html) on how to make Discord bot application and getting the bot token.\
Duplicate [`.env.example`](https://github.com/pollovolante/BanFromDiscord/blob/main/src/.env.example) and rename it as `.env`. Not `.env.txt`, **just `.env`**.\
**Now put the bot token into `.env`.**\
If you want you can also change the bot prefix in the same file.


## Add Roblox Script

Replace `ip` with your backend server's IP address on line 10 of [`BanHammer.lua`](https://github.com/pollovolante/BanFromDiscord/blob/main/BanHammer.lua).\
Then create a webhook into a log channel to receive info from the Roblox server and copy the webhook URL.
![Creating a webhook](https://www.minitool.com/images/uploads/news/2021/03/make-discord-webhooks-for-github/make-discord-webhooks-for-github-1.png)\
Now paste the webhook URL at line 9 of `BanHammer.lua`.\
Finally, select everything in `BanHammer.lua` and paste it into a script inside ServerScriptService.


## Running backend server

Now you only have to start up the backend server and Discord bot.\
Run `npm start` in your terminal and that's it!\
Time to destroy players from Discord >:D


## Commands Usage

### Duration arguments
| Actual duration | Passed argument |
|-|-|
| 30 minutes | `30m` |
| 2 hours | `2h` |
| 10 days | `10d` |
| 3 weeks | `3w` |

### Commands

**`§temp` - Temporary Ban**\
Usage: `§temp robloxUsername banDuration reason`\
Example 2 day ban: `§temp polloarrosto01 2d using exploits`

**`§gameban` - Permanent Ban**\
Usage: `§gameban robloxUsername reason`\
Example permanent ban: `§gameban polloarrosto01 exploiting noob`

**`§unban` - Unban**\
Usage: `§unban robloxUsername reason`\
Example unban: `§unban polloarrosto01 because yes`
