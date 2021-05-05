const fetch = require("node-fetch")

function parseTime(time) {
  if (typeof time === "string") {
    const timeObject = {
      m: 60,
      h: 3600,
      g: 86400,
      s: 604800
    }
    const digits = parseInt(time.match(/\d+/)[0])
    return timeObject[time.charAt(time.length - 1)] && digits * timeObject[time.charAt(time.length - 1)] || false
  }
}
module.exports = {
  name: "temp",
  description: "tempban",
  execute(message) {
    if (message.member.permissions.has('BAN_MEMBERS') || message.member.roles.cache.has("716256819093307392")) {
      const args = message.content.split(/ +/)
      args.shift()
      if (typeof args[0] === "string" && typeof args[1] === "string") {
        const playerName = args[0]
        const unixDiff = parseTime(args[1])
        if (!unixDiff) {
          return message.reply("Wrong Usage")
        }
        args.shift()
        args.shift()
        fetch("http://localhost:3000/ban", {
          headers: {
            'Content-Type': 'application/json'
          },
          method: "POST",
          body: JSON.stringify({
            playerName: playerName,
            time: unixDiff,
            reason: args.join(" "),
            author: message.member.displayName
          })
        })
      }
    }
  }
}
