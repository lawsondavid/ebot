# Description:
#   Use the mindmeister developer API to query the Corelogic org chart.
#
#   You must set the env variable HUBOT_MINDMEISTER_ACCESS_KEY using your personal access token provided by the
#   mindmeister development site.
#
#   A predefined MindMap id is used for the Corelogic org chart. If this id changes update the env
#   variable HUBOT_MINDMEISTER_DEFAULT_MAP_ID.
#
# Configuration
#   HUBOT_MINDMEISTER_ACCESS_KEY: 'abcdefghijklm'
#   HUBOT_MINDMEISTER_DEFAULT_MAP_ID: '12345'
#
# Commands:
#   hubot job role me <person-name> - Returns the job role for the person or the best possible match.
#   hubot job role me ALL - returns everyone's job role in the organisation.


module.exports = (robot) ->
  robot.respond /job role me (.*)/i, (msg) ->
    access_token = process.env.HUBOT_MINDMEISTER_ACCESS_KEY
    map_id = process.env.HUBOT_MINDMEISTER_DEFAULT_MAP_ID
    if !access_token
      msg.send "A problem occurred. Please contact your admin if the problem persists."
      return

    person_name = msg.match[1].trim()
    if !person_name
      msg.send "Please provide a name eg:/#{robot.name} job role me joe bloggs"
      return

    url = "https://www.mindmeister.com/services/rest/oauth2"
    query =
      method: 'mm.maps.getMap'
      map_id: map_id || '620074572'

    robot.http(url)
    .header('Authorization', "Bearer #{access_token}")
    .query(query)
    .get()((err, res, body) ->
      jsonBody = JSON.parse(body)
      mindMap = jsonBody.rsp
      if !mindMap or !mindMap.ideas or !mindMap.ideas.idea
        msg.send "Error: could not retrieve org chart."
        return

      people_roles = mindMap.ideas.idea.map (idea) -> if idea.title then idea.title.split('\n') else []

      if person_name.toLowerCase() == "all"
        msg.send "\n#{(people_roles.filter (person_role) -> person_role.length == 2).map((match) -> "• #{match}").join('\n')}"
        return

      matched_role = null
      people_roles.forEach (person_role) ->
        if person_role.length == 2 && person_role[0].toLowerCase() == person_name.toLowerCase()
          matched_role = person_role[1]

      if matched_role
        msg.send matched_role
      else
        possible_matches = people_roles.filter (person_role) -> person_role.length == 2 && person_role[0].toLowerCase().indexOf(person_name.toLowerCase()) > -1
        if possible_matches.length > 0
          msg.send "We could not find #{person_name}. Possible matches:\n #{possible_matches.map((match) -> "• #{match}").join('\n')}"
        else
          msg.send "No matching records"
    )

