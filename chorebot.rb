require 'pry'
require 'httparty'

def member_names
  HTTParty.get(ENV['SLACK_MEMBERS_URL'])['members'].each_with_object([]) do |member, names|
    names << member['name'] unless member['is_restricted']
  end
end

def post_message(message)
  params = { text: message, username: 'chorebot', icon_emoji: ':shipit:' }
  HTTParty.post(ENV['SLACK_WEBHOOK_URL'], body: params.to_json)
end

def current_trash_assignee
  candidates = member_names
  weekday_of_year = Date.today.cweek*5 + Date.today.wday
  candidates[weekday_of_year % candidates.length]
end

def morning_trash_message
  post_message("Good morning <@#{current_trash_assignee}>! It's your turn to take out the trash!")
end

def afternoon_trash_message
  post_message("Good afternoon <@#{current_trash_assignee}>! Did you remember to take out the trash?")
end

def weekly_cleanup_message
  post_message("Hey <@channel>, time to clean up the office!")
end
