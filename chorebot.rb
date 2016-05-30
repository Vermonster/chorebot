require 'pry'
require 'httparty'
require 'digest'
require_relative './lib/chore'

def member_names
  HTTParty.get(ENV['SLACK_MEMBERS_URL'])['members'].each_with_object([]) do |m, names|
    names << m['name'] if m['profile']['email'] =~ /vermonster.com$/ && !m['deleted']
  end
end

def chores
  roster = member_names
  [
    TrashChore.new(
      roster: roster,
      scheduling: WeeklyScheduling.new([:monday, :wednesday, :friday]),
      n_assignees: 2
    ),
    RecyclingChore.new(
      roster: roster,
      scheduling: WeeklyScheduling.new([:monday, :thursday])
    ),
    DishChore.new(
      roster: roster,
      scheduling: DailyScheduling.new
    ),
    PlantChore.new(
      roster: roster,
      name: 'Bertha',
      heading: 'h.sl24hns7ta7c',
      image_path: "bertha.jpg",
      scheduling: MonthlyScheduling.new
    ),
    PlantChore.new(
      roster: roster,
      name: 'Edward',
      heading: 'h.wlvxy5bc7z7d',
      image_path: "edward.jpg",
      scheduling: MonthlyScheduling.new,
      offset: 1
    ),
    PlantChore.new(
      roster: roster,
      name: 'Lula',
      heading: 'h.nvlbm0zacdtz',
      image_path: "lula.jpg",
      scheduling: MonthlyScheduling.new,
      offset: 2
    ),
    PlantChore.new(
      roster: roster,
      name: 'Maud, Frank, and Henri',
      heading: 'h.pzcfgmk69r6q',
      image_path: 'maud_frank_and_henri.png',
      scheduling: MonthlyScheduling.new,
      offset: 3
    ),
    PlantChore.new(
      roster: roster,
      name: 'Chester',
      heading: 'h.7ymknjojnom7',
      image_path: 'chester.jpg',
      scheduling: EveryNDaysScheduling.new(20)
    ),
    PlantChore.new(
      roster: roster,
      name: 'Myrtle',
      heading: 'h.2lttmnmb2ozt',
      image_path: 'myrtle.png',
      scheduling: WeeklyScheduling.new([:monday])
    )
  ]
end

def morning_chore_messages
  chores.select(&:run_today?).each(&:morning_post)
end

def afternoon_chore_messages
  chores.select(&:run_today?).each(&:afternoon_post)
end

def rotating_store(day = Date.today)
  ['HMart', 'Star Market', 'Whole Foods'][day.cweek % 3]
end

def post_message(message, username='chorebot', icon_emoji=':shipit:')
  params = { text: message, username: username, icon_emoji: icon_emoji }
  HTTParty.post(ENV['SLACK_WEBHOOK_URL'], body: params.to_json)
end

def weekly_cleanup_message
  post_message("Hey <!channel>, time to clean up the office!")
  if rand < 0.5
    post_message("Also, remember to order <http://inst.cr/t/yaQhcx|snacks>, my precious :ring:", "Snack Gollum", ":gollum:")
  else
    post_message("Also, if you want to \"see more\" snacks, <http://inst.cr/t/yaQhcx|order some>.", "Snack Audrey II", ":feedme:")
  end
end

def weekly_snack_message
  post_message "It's snack time! <http://inst.cr/t/yaQhcx|Here's the cart>. This week, we suggest #{rotating_store}. :gollum:"
end
