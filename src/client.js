const { Client, Collection, Intents } = require("discord.js");

const myClient = class extends Client {
	constructor(config) {
		super({
			disableEveryone: true,
			disabledEvents: ["TYPING_START"],
		});

		this.commands = new Collection();
		this.queue = new Collection();
		this.config = config;
	}
};

module.exports = new myClient({ ws: { intents: Intents.ALL } });