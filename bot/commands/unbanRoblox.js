const fetch = require("node-fetch")
module.exports = {
  name: "unban",
  description: "unban name reason",
  execute(message) {
    if (message.member.permissions.has('BAN_MEMBERS')) {
      const args = message.content.split(/ +/)
      args.shift()
      if (typeof args[0] === "string" && typeof args[1] === "string") {
        const playerName = args[0]
        args.shift()
        fetch("https://api.roblox.com/users/get-by-username?username=" + playerName).then(response => response.json()).then(data => {
          fetch("http://localhost:3000/ban", {
            headers: {
              'Content-Type': 'application/json'
            },
            method: "POST",
            body: JSON.stringify({
              playerName: playerName,
              time: 0,
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