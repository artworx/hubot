# Description:
#   KPI
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   kpi <user name> - list the last 10 quotes for a user
#   kpi++ <user name> - kpi++ for last user comment
#   kpi-- <user name> - kpi-- for last user comment
#
# Author:
#   Akeszeg
#
class Message
  constructor: (@user, @text, @thumbs) ->
    @createdAt = new Date()

QuoteService =
  messageKey: (userName) ->
    "messages_#{userName}"

  add: (robot, userName, message) ->
    messages = @get(robot, userName)
    messages.push(message)
    @save(robot, userName, messages[-10..])
    message

  addUp: (robot, userName, text) ->
    message = new Message(userName, text, ':thumbsup:')
    @add(robot, userName, message)

  addDown: (robot, userName, text) ->
    message = new Message(userName, text, ':thumbsdown:')
    @add(robot, userName, message)

  save: (robot, userName, messages) ->
    robot.brain.set(@messageKey(userName), messages)

  get: (robot, userName) ->
    robot.brain.get(@messageKey(userName)) or []

  formatMessage: (message) ->
    "#{message.thumbs} [#{message.createdAt}]  - '#{message.text}'"

KpiService =
  messageKey: (userName) ->
    "kpi_#{userName}"

  increment: (robot, userName) ->
    kpi = @get(robot, userName)
    kpi += 1
    @set(robot, userName, kpi)

  decrement: (robot, userName) ->
    kpi = @get(robot, userName)
    kpi -= 1
    @set(robot, userName, kpi)

  get: (robot, userName)->
    robot.brain.get(@messageKey(userName)) * 1 or 0

  set: (robot, userName, value)->
    robot.brain.set(@messageKey(userName), value)
    value

module.exports = (robot) ->
  context = {}

  robot.hear /^kpi\+\+ (.*)/i, (res) ->
    user = res.match[1]

    if msg = context[user]
      if user == res.message.user.name
        res.send "NO!"
      else
        message = QuoteService.addUp(robot, msg.user.name, msg.text)
        kpi = KpiService.increment(robot, msg.user.name)

        res.send "
           KPI #{user}: #{kpi}\n
           > #{QuoteService.formatMessage(message)}
        "

  robot.hear /^kpi-- (.*)/i, (res) ->
    user = res.match[1]

    if msg = context[user]
      if user == res.message.user.name
        res.send "NO!"
      else
        message = QuoteService.addDown(robot, msg.user.name, msg.text)
        kpi = KpiService.decrement(robot, msg.user.name)

        res.send "
           KPI #{user}: #{kpi}\n
           > #{QuoteService.formatMessage(message)}
        "

  robot.hear /^kpi (.*)/i, (res) ->
    user = res.match[1]

    messages = QuoteService.get(robot, user)
    kpi = KpiService.get(robot, user)

    messages = messages.map (msg) ->
      QuoteService.formatMessage(msg)
    .join("\n")
    res.send "
      KPI #{user} #{kpi}\n
      #{messages}
    "

  robot.hear /.*/, (res) ->
    context[res.message.user.name] = res.message

