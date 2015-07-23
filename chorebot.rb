require 'pry'
require 'httparty'
require 'digest'

def member_names
  HTTParty.get(ENV['SLACK_MEMBERS_URL'])['members'].each_with_object([]) do |m, names|
    names << m['name'] if m['profile']['email'] =~ /vermonster.com$/ && !m['deleted']
  end
end

def post_message(message)
  params = { text: message, username: 'chorebot', icon_emoji: ':shipit:' }
  HTTParty.post(ENV['SLACK_WEBHOOK_URL'], body: params.to_json)
end

def assignees_for(day, candidates, number_of_chores = 3 )
  weekday_of_year = day.cweek * 5 + day.wday
  start_value = 5
  seq = number_of_chores * weekday_of_year + start_value

  number_of_chores.times.map { |i| candidates[(seq + i) % candidates.length] }
end

def assign_chores(date = Date.today)
  member1, member2, member3  = assignees_for(date, member_names).shuffle
  {
    trash: "<@#{member1}> and <@#{member2}>",
    dishes: "<@#{member3}>"
  }
end

def morning_chore_message
  current_assignees = assign_chores
  post_message("Good morning #{current_assignees[:trash]}! It\'s your turn to take out the trash!")
  post_message("And howdy #{current_assignees[:dishes]}. You are in charge of dishes.")
end

def afternoon_chore_message
  current_assignees = assign_chores
  post_message("#{current_assignees[:trash]}! Did you remember to take out the trash?")
  post_message("Oh, and  #{current_assignees[:dishes]}, did you remember the dishes?")
end

def weekly_cleanup_message
  post_message("Hey <!channel>, time to clean up the office!")
end

def weekly_snack_message
  candidates = member_names.sort_by { |name| Digest::SHA256.hexdigest(name) }
  snack_czar = candidates[Date.today.cweek % candidates.length]
  post_message("I hereby appoint <@#{snack_czar}> to be this week's Snack Czar")
end

def random_morning_message
  post_message("Give a little shout-out to <@#{member_names.sample}>!")
end
