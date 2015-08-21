# Description:
#   "Makes your Hubot even more Clever™"
#
# Dependencies:
#   "cleverbot-node": "0.2.1"
#
# Configuration:
#   None
#
# Commands:
#   hubot c <input>
#
# Author:
#   ajacksified
#   Stephen Price <steeef@gmail.com>

cleverbot = require('cleverbot-node')

module.exports = (robot) ->
  c = new cleverbot()

  robot.hear /c?bordei(bot)? (.*)/i, (msg) ->
    data = msg.match[2].trim()
    cleverbot.prepare(( -> c.write(data, (c) => msg.send(c.message))))
