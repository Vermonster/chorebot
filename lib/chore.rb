require_relative './scheduling'

class Chore
  attr_reader :scheduling, :n_assignees, :offset, :roster

  def initialize(scheduling:, roster:, n_assignees: 1, offset: 0)
    @scheduling = scheduling
    @n_assignees = n_assignees
    @offset = offset # to control which member starts, not anything date-related
    @roster = roster
  end

  def run_today?
    scheduling.run_today?
  end

  def next_run_date
    scheduling.next_run_date
  end

  def assignees_on(date)
    index = n_assignees * scheduling.run_index_on(date) + offset
    index.upto(index + n_assignees - 1).map do |i|
      roster[i % roster.length]
    end
  end

  def assignees
    assignees_on(Date.today)
  end

  def assignee_mentions
    assignees.map { |a| "<@#{a}>" }.join(' and ')
  end

  def icon_params
    { icon_emoji: ':shipit:', username: 'chorebot' }
  end

  def post(message)
    params = { text: message }.merge(icon_params)
    HTTParty.post(ENV['SLACK_WEBHOOK_URL'], body: params.to_json)
  end

  def morning_post
    post morning_message
  end

  def afternoon_post
    post afternoon_message
  end
end

class TrashChore < Chore
  def morning_message
    "Hi #{assignee_mentions}, it's your turn to take out the trash (bags out after 5pm)."
  end

  def afternoon_message
    "Hi #{assignee_mentions}, did you remember to take out the trash? Remember, bags out after 5pm."
  end
end

class RecyclingChore < Chore
  def morning_message
    "Hey #{assignee_mentions}, you're on recycling."
  end

  def afternoon_message
    "Hey #{assignee_mentions}, just a reminder to take out the recycling (bags out after 5)."
  end
end

class PlantChore < Chore
  attr_reader :name, :heading, :image_path

  def initialize(scheduling:, roster:, n_assignees: 1, offset: 0, name:, heading:, image_path:)
    @name = name
    @scheduling = scheduling
    @n_assignees = n_assignees
    @offset = offset
    @roster = roster
    @name = name
    @heading = heading
    @image_path = image_path
  end

  def icon_params
    { icon_url: "#{ENV['PLANT_IMG_URL']}/#{image_path}", username: name }
  end

  def morning_message
    "Hello #{assignee_mentions}, could you please water me today? <#{ENV['PLANT_DOC_URL']}#heading=#{heading}|Instructions here!>"
  end

  def afternoon_message
    "Hey #{assignee_mentions}, did you remember to water me today? <#{ENV['PLANT_DOC_URL']}#heading=#{heading}|Instructions here!>"
  end
end

class DishChore < Chore
  def morning_message
    "Good morning #{assignee_mentions}, you're on dishes today."
  end

  def afternoon_message
    "Hey everyone, please don't forget to wash your dishes so #{assignee_mentions} won't have to!"
  end
end
