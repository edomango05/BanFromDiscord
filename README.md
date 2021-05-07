# SETUP
clone the repository with `git clone https://github.com/pollovolante/BanFromDiscord.git` or install the zip file
## Installation 
install [node.js](https://nodejs.org/en/)

## Dependencies 
run `npm i` into you terminal or console

## Discord Bot
[here](https://www.howtogeek.com/364225how-to-make-your-own-discord-bot/) you can find out how to make a discord bot app and how to get the token
**now put the discord bot token into [config.json file](https://github.com/pollovolante/BanFromDiscord/blob/main/bot/config.json)** (if you want you can also change the bot prefix there)
## Roblox Script config [BanHammer](https://github.com/pollovolante/BanFromDiscord/blob/main/BanHammer.lua)
put [BanHammer](https://github.com/pollovolante/BanFromDiscord/blob/main/BanHammer.lua) into ServerScriptService and configure it
with the ip of the webserver host replacing `ip` [here](https://github.com/pollovolante/BanFromDiscord/blob/main/BanHammer.lua#L10). Then create a [webhook](https://www.minitool.com/images/uploads/news/2021/03/make-discord-webhooks-for-github/make-discord-webhooks-for-github-1.png) into a log channel to receive info from the Roblox server and get the [webhook](https://www.minitool.com/images/uploads/news/2021/03/make-discord-webhooks-for-github/make-discord-webhooks-for-github-1.png) URL. Now you have to put this URL into the lua file ([here](https://github.com/pollovolante/BanFromDiscord/blob/main/BanHammer.lua#L10))
## Startup
Remains only to run the webserver and the bot! So click on the run.bat files that are into `./bot` and `./server` folders and ... that's it ! Now you can destroy players from discord >:D.
## Usage 
### Default commands

**tempban**
```
TimeTables

30 minutes = 20m
2 hours = 2h
80 days = 80d
3 weeks = 3w

``` 
example for ban 2 days
```
§temp polloarrosto01 2g exploits
``` 
`§temp robloxUsername [how much?] reason`

**permaban**
example 
```
§gameban polloarrosto01 exploits
``` 
`§gameban robloxUsername reason`


**unban**
example 
```
§unban polloarrosto01 because yes
``` 
`§unban robloxUsername reason`

