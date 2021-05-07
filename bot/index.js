// Create client
const client = require("./client");
const { commands } = client;

// Get configurations
const { token, prefix } = require("./config.json");

// Setup commands
require("fs").readdirSync("./commands")
	.filter(file => file.endsWith(".js"))
	.forEach(file => {
		let command = require(`./commands/${file}`);
		commands.set(command.name, command);
	});

// On ready
client.once("ready", () => console.log("ready"));

// On new message
client.on("message", message => {
	const { author, content, channel } = message;

	// Checks
	if (author.bot) return;
	if (!content.startsWith(prefix)) return;

	// Get arguments and command
	const args = content.slice(prefix.length).split(/ +/);
	const command = commands.get(args.shift().toLowerCase());

	if (command) {
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