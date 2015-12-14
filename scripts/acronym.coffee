# Description:
#   Stores acronyms used be Corelogic.
#
#   Acronyms are persisted in redis.
# Dependencies:
#   redis-brain
#
# Configuration
#   REDISCLOUD_URL: 'endpoint-provided-by-redis-cloud'
#
# Commands:
#   hubot acro <acronym> - Returns definition of acronym e.g. hubot acro BA -> Business Analyst
#   hubot acro ALL - Returns all acronyms
#   hubot acro -add <acronym>:<description> - Adds acronym e.g. hubot add acro BA:Business Analyst
#   hubot acro -delete <acronym> - Deletes acronym e.g. hubot delete BA
#

module.exports = (robot) ->
  acronymsPrefix = 'acronyms'
###
  getAcronyms () -> robot.brain.get(acronymsPrefix) || {}

  saveAcronyms (acronyms) -> robot.brain.save(acronymsPrefix, acronyms)

  addAcronym (acronym, description) ->
    acronyms = getAcronyms()
    acronyms[acronym] = description
    saveAcronyms(acronyms)

  deleteAcronym (acronym) ->
    acronyms = getAcronyms()
    delete acronyms[acronym]
    saveAcronyms(acronyms)

  robot.respond /acro (.*)/i, (msg) ->
    acronym = msg.match[1].trim().toUpperCase()
    acronyms = getAcronyms().sort()
    if description == 'ALL'
      for k of Object.keys(acronym).sort()
        msg.send "#{k} - #{acronyms[k]}\n"
    else
      description = acronyms[acronym]
      if description
        msg.send "#{acronym} - #{description}"
      else
        msg.send "Acronym #{acronym} not defined. If you find out what it means please tell #{robot.name} e.g. #{robot.name} acro -add <acronym>:<description>"

  robot.respond /acro -add (.*)/i, (msg) ->
    acronym_to_add = msg.match[1].trim().split(':')
    if acronym_to_add.length != 2
      msg.send "Invalid format. Expected:\n#{robot.name} acro -add <acronym>:<description> - Adds acronym e.g. #{robot.name} add acro BA:Business Analyst"
    else
      robot.brain.save(acronym_to_add[0].toUpperCase(), acronym_to_add[1])
      msg.send "#{acronym_to_add[0]} added"

  robot.respond /acro -delete (.*)/i, (msg) ->
    acronym = msg.match[1].trim().toUpperCase()
    deleteAcronym(acronym)
    msg.send "#{acronym} deleted"###
