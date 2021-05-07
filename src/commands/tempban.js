const { get, post } = require("axios").default;

const parseTime = time => {
	const timeObject = { m: 60, h: 3600, d: 86400, w: 604800 };
	let [_, n, unit] = time.match(/(\d+)(\w)/);
	n = parseInt(n);
	if (!(n && timeObject[unit])) return false;
	return n * timeObject[unit];
}

module.exports = {
	name: "temp",
	description: "Temporarily ban a user from the game",
	args: true,
	usage: "robloxUsername banDuration reason",
	permission: "BAN_MEMBERS",
	execute(message, args) {
		const { author, channel } = message;

		if (args[2] === undefined)
			return channel.send(":x: Incorrect usage. To view correct usage please rerun this command without any arguments");
		const playerName = args.shift();
		const unixDiff = parseTime(args.shift());
		if (!unixDiff || unixDiff <= 0)
			return channel.send(":x: Please provide a valid duration. Example: 5 hours = `5h`, 3 days = `3d`");

		get(`https://api.roblox.com/users/get-by-username?username=${playerName}`)
			.then(({ data }) => {
				if (data.success === false)
					return channel.send(`:x: ${data.errorMessage}`);
				post("http://localhost:3000/ban", {
					playerName,
					playerid: data.Id,
					time: unixDiff,
					reason: args.join(" "),
					author: author.username
				})
			})
			.catch(console.log);
	}
}