const fs = require('fs')
const Discord = require('discord.js');
const Client = require('./client/Client');
const { token, prefix, StatuServer } = require('./config.json');
const client = new Client({ ws: { intents: Discord.Intents.ALL } });
Main.client = client
client.commands = new Discord.Collection();
const commandFiles = fs.readdirSync("../bot/botpalermo/commands").filter(file => file.endsWith('.js'));
for (const file of commandFiles) {
  const command = require(`./commands/${file}`);
  client.commands.set(command.name, command);
}
console.log(client.commands);
client.once('ready', () => {
  console.log('ready');
});
client.once('reconnecting', () => {
  console.log('reconnecting');
});
client.once('disconnect', () => {
  console.log('disconnecting');
});
client.on('message', async message => {
  const args = message.content.slice(prefix.length).split(/ +/);
  const commandName = args.shift().toLowerCase();
  const command = client.commands.get(commandName);
  if (message.author.bot) return;
  if (!message.content.startsWith(prefix)) return;
  try {
    if (command) {
      command.execute(message);
    }
  } catch (error) {
    console.log(error)
  }
});
client.login(token)