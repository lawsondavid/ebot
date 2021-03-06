# Description:
#   Stores acronyms used be Corelogic.
#
#   Acronyms are persisted in redis.
# Dependencies:
#   "redis-brain": "x.x.x"
#   "underscore": "1.3.3"
#
# Configuration
#   REDISCLOUD_URL: 'endpoint-provided-by-redis-cloud'
#
# Commands:
#   hubot acro <acronym> - Returns definition of acronym e.g. hubot acro BA -> Business Analyst
#   hubot acro ALL - Returns all acronyms
#   hubot acro-add <acronym>:<description> - Adds acronym e.g. hubot acro-add BA:Business Analyst
#   hubot acro-delete <acronym> - Deletes acronym e.g. hubot acro-delete BA
#
#

_ = require("underscore")

module.exports = (robot) ->
  robot.respond /acro (.*)/i, (msg) ->
    acronym = msg.match[1].trim().toUpperCase()
    acronyms = getAcronyms(robot)
    if acronym == 'ALL'
      keys = _.keys(acronyms).sort()
      for k in keys
        msg.send "#{k} - #{acronyms[k]}"
    else
      description = acronyms[acronym]
      if description
        msg.send "#{acronym} - #{description}"
      else
        msg.send "Acronym #{acronym} not defined. If you find out what it means please tell #{robot.name} e.g. #{robot.name} acro -add <acronym>:<description>"

  robot.respond /acro-add (.*)/i, (msg) ->
    acronym_to_add = msg.match[1].trim().split(':')
    if acronym_to_add.length != 2
      msg.send "Invalid format. Expected:\n#{robot.name} acro -add <acronym>:<description> - Adds acronym e.g. #{robot.name} add acro BA:Business Analyst"
    else
      addAcronym(robot, acronym_to_add[0].toUpperCase(), acronym_to_add[1])
      msg.send "#{acronym_to_add[0]} added"

  robot.respond /acro-delete (.*)/i, (msg) ->
    acronym = msg.match[1].trim().toUpperCase()
    deleteAcronym(robot, acronym)
    msg.send "#{acronym} deleted"

acronymsPrefix = 'acronyms'

getAcronyms = (robot) -> robot.brain.get(acronymsPrefix) || {}

saveAcronyms = (robot, acronyms) ->
  robot.brain.set(acronymsPrefix, acronyms)
  robot.brain.save()

addAcronym = (robot, acronym, description) ->
  acronyms = getAcronyms(robot)
  acronyms[acronym] = description
  saveAcronyms(robot, acronyms)

deleteAcronym = (robot, acronym) ->
  acronyms = getAcronyms(robot)
  delete acronyms[acronym]
  saveAcronyms(robot, acronyms)
