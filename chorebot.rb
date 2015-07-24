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

def chore_assignees(date = Date.today)
  # pick the next three vermonsters who should get chores, then randomize
  # which ones they get
  assignees_for(date, member_names, 3, 2).shuffle(random: random_for(date))
end

def snack_czar
  # cycle through vermonsters at a rate of one per week
  # but using a different order than we do for chores
  candidates = member_names.sort_by { |name| Digest::SHA256.hexdigest(name) }
  candidates[Date.today.cweek % candidates.length]
end

def morning_chore_message
  t1, t2, d = chore_assignees
  post_message("Good morning <@#{t1}> and <@#{t2}>! It's your turn to take out the trash!\nAnd howdy, <@#{d}>. You're on dishes.")
end

def afternoon_chore_message
  t1, t2, d = chore_assignees
  post_message("Good afternoon <@#{t1}> and <@#{t2}>! Did you remember to take out the trash?\nAnd everyone else, please clean any remaining dishes so <@#{d}> doesn't have to!")
end

def weekly_cleanup_message
  post_message("Hey <!channel>, time to clean up the office!")
end

def weekly_snack_message
  m = "I hereby appoint <@#{snack_czar}> to be this week's Snack Czar/ina.\nForgot what to do? <https://docs.google.com/document/d/1ZM1W3eJc4qX2-OJamy4-K4lXrPczgk-VO8hlOFdPbq0/edit|Click here!>"
  post_message(rand < 0.05 ? rr(m) : m)
end

# pseudo-private methods

def random_for(date)
  # random seed deterministically generated from the date, so the "shuffling"
  # is the same in the morning and afternoon
  Random.new(date.to_time.to_i)
end

def assignees_for(day, candidates, number_of_chores, offset = 0)
  # cycle through the weekdays of the year to pick a different set
  # of {number_of_chores} candidates each weekday
  weekday_of_year = day.cweek * 5 + day.wday
  seq = number_of_chores * weekday_of_year + offset
  number_of_chores.times.map { |i| candidates[(seq + i) % candidates.length] }
end

def rr(message_with_link)
  message_with_link.sub(/<[^>]+\|([^>]+)>/) { "<https://www.youtube.com/watch?v=oHg5SJYRHA0|#{$1}>" }
end
