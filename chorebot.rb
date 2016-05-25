require 'pry'
require 'httparty'
require 'digest'
require_relative './plants'

CHOREBOT_URL = 'https://mysterious-fortress-9011.herokuapp.com'
PLANT_URL = 'https://docs.google.com/document/d/1HEjcqnwFoUmNvBTviB_0V4vRQM9ERj3GbxMCp8dNY7A'
PLANT_CHORE_BLACKLIST = [] # add your slack name here if you want to opt out of plant duties
INACTIVE_MEMBER_NAMES = %w(belac)

def member_names
  HTTParty.get(ENV['SLACK_MEMBERS_URL'])['members'].each_with_object([]) do |m, names|
    names << m['name'] if m['profile']['email'] =~ /vermonster.com$/ && !m['deleted']
  end - INACTIVE_MEMBER_NAMES
end

def post_message(message, username='chorebot', icon_emoji=':shipit:')
  params = { text: message, username: username, icon_emoji: icon_emoji }
  HTTParty.post(ENV['SLACK_WEBHOOK_URL'], body: params.to_json)
end

def chores

end

def morning_chore_messages
  chores_today = chores.select(&:run_today?).map(&:morning_assignment_message)
  if chores_today.count > 0
    post_message("Chores for today:\n#{chores_today.join("\n")}")
  end
end

def afternoon_chore_messages
  chores_today = chores.select(&:run_today?).map(&:afternoon_assignment_message)
  if chores_today.count > 0
    post_message(chores_today.join("\n"))
  end
end


def chore_assignees(date = Date.today)
  # pick the next three vermonsters who should get chores, then randomize
  # which ones they get
  assignees_for(date, member_names, 3, 2).shuffle(random: random_for(date))
end

def rotating_store(day = Date.today)
  ['HMart', 'Star Market', 'Whole Foods'][day.cweek % 3]
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
  if coinflip
    post_message("Also, remember to order <http://inst.cr/t/yaQhcx|snacks>, my precious :ring:", "Snack Gollum", ":gollum:")
  else
    post_message("Also, if you want to \"see more\" snacks, <http://inst.cr/t/yaQhcx|order some>.", "Snack Audrey II", ":feedme:")
  end
end

def weekly_snack_message
  post_message "It's snack time! <http://inst.cr/t/yaQhcx|Here's the cart>. This week, we suggest #{rotating_store}. :gollum:"
end

def plant_chore_messages
  PLANTS.each do |name, plant|
    if plant[:scheduling].run_today?
      assignee = plant_assignee_for(plant[:scheduling].next_index)
      params = {
        username: plant[:name],
        text: "Hey <@#{assignee}>, could you please water me today? <#{PLANT_URL}#heading=#{plant[:heading]}|Instructions here!>",
        icon_url: "#{CHOREBOT_URL}/#{plant[:image_path]}"
      }
      HTTParty.post(ENV['SLACK_WEBHOOK_URL'], body: params.to_json)
    end
  end
end

# pseudo-private methods

def plant_assignee_for(index)
  candidates = member_names - PLANT_CHORE_BLACKLIST
  candidates[index % candidates.length]
end

def coinflip
  rand < 0.5
end

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
