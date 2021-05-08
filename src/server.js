// Modules
const express = require("express");
const bodyparser = require("body-parser");
const { EventEmitter } = require("events");

// Constants
const events = new EventEmitter();
const port = 3000;

// Ban cache
let ban = [];

// Express app
const app = express();
app.use(bodyparser.json());

// Roblox server request bans from webserver
// Waits until discord bot sends ban data
app.get("/ban", (_req, res) =>
	events.once("banEvent", bans => {
		res.json(bans)
		ban = [];
	})
);

// Discord bot sends ban data to webserver
app.post("/ban", (req, res) => {
	ban.push(req.body);
	events.emit("banEvent", ban);
});

// Send status 200 to client
app.get("/", (_req, res) => res.sendStatus(200));

// Start webserver
app.listen(port, () => console.log(`Webserver: Listening on port ${port}`));
