module.exports = (robot) ->
  robot.router.get '/status', (req, res) ->
    res.send 'OK'
