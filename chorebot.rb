require 'pry'
require 'httparty'

def member_names
  HTTParty.get(ENV['SLACK_MEMBERS_URL'])['members'].each_with_object([]) do |m, names|
    names << m['name'] if m['profile']['email'] =~ /vermonster.com$/ && !m['deleted']
  end
end

def post_message(message)
  params = { text: message, username: 'chorebot', icon_emoji: ':shipit:' }
  HTTParty.post(ENV['SLACK_WEBHOOK_URL'], body: params.to_json)
end

def assignees_for(day, candidates)
  i1 = 2*(day.cweek*5 + day.wday) + 5
  i2 = i1 + 1
  member1 = candidates[i1 % candidates.length]
  member2 = candidates[i2 % candidates.length]
  [member1, member2]
end

def current_trash_assignees
  member1, member2 = assignees_for(Date.today, member_names)
  "<@#{member1}> and <@#{member2}>"
end

def morning_trash_message
  post_message("Good morning #{current_trash_assignees}! It's your turn to take out the trash!")
end

def afternoon_trash_message
  post_message("Good afternoon #{current_trash_assignees}! Did you remember to take out the trash?")
end

def weekly_cleanup_message
  post_message("Hey <@channel>, time to clean up the office!")
end
