const express = require("express");
const bodyparser = require("body-parser")

module.exports = class Server {
  constructor() {
    this.app = express()
    this.ban = []
  }
  routing() {
    try {
      this.app.use(bodyparser.json())
      this.app.get('/ban', (req, res) => {
        res.json(this.ban)
        this.ban = []
      })
      this.app.post('/ban', (req, res) => {
        this.ban.push(req.body)
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