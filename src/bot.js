// Modules
const { readdirSync } = require("fs");
const path = require("path");

// Create client
const client = require("./client");
const { commands } = client;

// Get configurations
const { TOKEN: token, PREFIX: prefix } = process.env;

// Setup commands
readdirSync(path.join(__dirname, "/commands"))
	.filter(file => file.endsWith(".js"))
	.forEach(file => {
		let command = require(`./commands/${file}`);
		commands.set(command.name, command);
	});

// On ready
client.once("ready", () => console.log(`Discord bot: ${client.user.tag} is ready`));

// On new message
client.on("message", message => {
	const { author, content, channel } = message;

	// Checks
	if (channel.type === "dm" || author.bot || !content.startsWith(prefix)) return

	// Get arguments and command
	const args = content.slice(prefix.length).split(/ +/);
	const command = commands.get(args.shift().toLowerCase());

	if (command) {
		// Permission check
		if (command.permission) {
			const perms = channel.permissionsFor(author);
			if (!(perms && perms.has(command.permission))) return;
		}
		// Arguments check
		if (command.args && !args.length) {
			let reply = ":x: No arguments provided";
			if (command.usage)
				reply += `\nUsage: \`${prefix}${command.name} ${command.usage}\``;
			return channel.send(reply);
		}
		// Try executing the command
		try {
			command.execute(message, args);
		} catch(e) {
			console.log(e);
			channel.send(":x: An error occurred");
		}
	}
});

// Login
client.login(token);
