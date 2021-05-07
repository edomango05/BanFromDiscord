// Configure environment variables
const dotenv = require("dotenv");
dotenv.config();

//Load webserver and Discord bot
require("./server");
require("./bot");
