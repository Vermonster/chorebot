require 'pry'
require 'httparty'
require 'digest'
require_relative './lib/schedulings'
require_relative './lib/chores'

NO_CHORE_LIST = %w(paul asross jordanking ceren drew)
INSTACART_STORES = ['HMart', 'Star Market', 'Whole Foods']

def chores
  [
    TrashChore.new(
      scheduling: WeeklyScheduling.new([:tuesday, :friday]),
      n_assignees: 2,
      offset: -8
    ),
    RecyclingChore.new(
      scheduling: WeeklyScheduling.new([:thrusday]),
      offset: -5
    ),
    DishChore.new(
      scheduling: DailyScheduling.new,
      offset: -4
    ),
    PlantChore.new(
      name: 'Lula',
      heading: 'h.nvlbm0zacdtz',
      image_path: "lula.jpg",
      scheduling: MonthlyScheduling.new,
      offset: 2
    ),
    PlantChore.new(
      name: 'Chester',
      heading: 'h.7ymknjojnom7',
      image_path: 'chester.jpg',
      scheduling: EveryNDaysScheduling.new(20)
    )
  ]
end

def morning_chore_messages
  chores.select(&:run_today?).each(&:morning_post)
end

def afternoon_chore_messages
  chores.select(&:run_today?).each(&:afternoon_post)
end

def post_message(message, username='chorebot', icon_emoji=':shipit:')
  params = { text: message, username: username, icon_emoji: icon_emoji }
  HTTParty.post(ENV['SLACK_WEBHOOK_URL'], body: params.to_json)
end

def weekly_cleanup_message
  post_message("Hey <!channel>, time to clean up the office!")
  if rand < 0.5
    post_message("Also, remember to order <#{ENV['INSTACART_URL']}|snacks>, we suggest #{this_weeks_store}, my precious :ring:", "Snack Gollum", ":gollum:")
  else
    post_message("Also, if you want to \"see more\" snacks, <#{ENV['INSTACART_URL']}|order some>. We suggest #{this_weeks_store},", "Snack Audrey II", ":feedme:")
  end
end

def weekly_snack_message
  post_message "It's snack time! <#{ENV['INSTACART_URL']}|Here's the cart>. This week, we suggest #{rotating_store}. :gollum:"
end

def rotating_store(day = Date.today)
  INSTACART_STORES[day.cweek % 3]
end

def this_weeks_store
  INSTACART_STORES[(Date.today.cweek-1) % 3]
end
