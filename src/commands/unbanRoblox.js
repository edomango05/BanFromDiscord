const { get, post } = require("axios").default;

module.exports = {
	name: "unban",
	description: "Unban a user from the game",
	args: true,
	usage: "robloxUsername reason",
	permission: "BAN_MEMBERS",
	execute(message, args) {
		const { author, channel } = message;

		if (args[1] === undefined)
			return channel.send(":x: Incorrect usage. To view correct usage please rerun this command without any arguments");
		const playerName = args.shift();

		get(`https://api.roblox.com/users/get-by-username?username=${playerName}`)
			.then(({ data }) => {
				if (data.success === false)
					return channel.send(`:x: ${data.errorMessage}`);
				post("http://localhost:3000/ban", {
					playerName,
					playerid: data.Id,
					time: 0,
					reason: args.join(" "),
					author: author.username
				})
			})
			.catch(console.log);
	}
}