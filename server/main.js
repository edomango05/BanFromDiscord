const Server = require("./api/routing")
async function main() {
  const server = new Server()
  await server.routing()
}
main()