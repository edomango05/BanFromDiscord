const fetch = require("node-fetch")

function parseTime(time) {
  if (typeof time === "string") {
    const timeObject = {
      m: 60,
      h: 3600,
      d: 86400,
      w: 604800
    }
    const digits = parseInt(time.match(/\d+/)[0])
    return timeObject[time.charAt(time.length - 1)] && digits * timeObject[time.charAt(time.length - 1)] || false
  }
}
module.exports = {
  name: "temp",
  description: "tempban name time reason",
  execute(message) {
    if (message.member.permissions.has('BAN_MEMBERS')) {
      const args = message.content.split(/ +/)
      args.shift()
      if (typeof args[0] === "string" && typeof args[1] === "string") {
        const playerName = args[0]
        const unixDiff = parseTime(args[1])
        if (!unixDiff || unixDiff === 0) {
          return message.reply("Utilizzo sbagliato")
        }
        args.shift()
        args.shift()
        fetch("https://api.roblox.com/users/get-by-username?username=" + playerName).then(response => response.json()).then(data => {
          fetch("http://localhost:3000/ban", {
            headers: {
              'Content-Type': 'application/json'
            },
            method: "POST",
            body: JSON.stringify({
              playerName: playerName,
              time: unixDiff,
              playerid: data.Id,
              reason: args.join(" "),
              author: message.member.displayName
            })
          })
        })
      }
    }
  }
}
