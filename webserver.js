class Server {
    constructor() {
      this.ban = []
    }
    routing() {
      try {
        this.app = express()
        this.app.use(bodyparser.json())
        this.app.get('/ban', (req, res) => {
          res.json(this.ban)
          this.ban = []
        })
        this.app.post('/ban', async(req, res) => {
          console.log(req.body)
          this.ban.push(req.body)
        })
      }catch(e){console.error(e)}
    }
}
