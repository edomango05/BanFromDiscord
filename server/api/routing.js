const express = require("express");
const bodyparser = require("body-parser")
const EventEmitter = require("events").EventEmitter
const eventHandler = new EventEmitter()
module.exports = class Server {
  constructor() {
    this.app = express()
    this.ban = []
  }
  routing() {
    try {
      this.app.use(bodyparser.json())
      this.app.get('/ban', (req, res) => {
        eventHandler.once("banEvent", (bans) => {
          res.json(bans)
          this.ban = []
        })
      })
      this.app.post('/ban', (req, res) => {
        this.ban.push(req.body)
        eventHandler.emit("banEvent", this.ban)
      })
      this.app.get("/", async(req, res) => res.sendStatus(200))
      const port = 3000
      return new Promise((res, rej) => {
        try {
          this.app.listen(port, () => console.log('listening on port... ' + port))
          res(true)
        } catch (e) {
          rej(e)
        }
      })
    } catch {
      throw new Error('Internal Error')
    }
  }
}