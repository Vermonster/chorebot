class Chore
  attr_reader :name, :scheduling, :n_assignees, :offset, :members

  def initialize(name:, scheduling:, members:, n_assignees: 1, offset: 0)
    @name = name
    @scheduling = scheduling
    @n_assignees = n_assignees
    @offset = offset # to control which member starts, not anything date-related
    @members = members
  end

  def run_today?
    scheduling.run_today?
  end

  def next_run_date
    scheduling.next_run_date
  end

  def run_indexes_on(date)
    base_index = assignees_per_task * scheduling.run_index_on(date) + offset
    base_index.upto(base_index + assignees_per_task).to_a
  end

  def assignees_on(date)
    run_indexes_on(date).map { |i| members[i % members.length] }
  end

  def assignees
    assignees_on(Date.today)
  end

  def assignee_mentions
    assignees.map { |a| "<@#{a}>" }.to_sentence
  end

  def username
    'chorebot'
  end

  def icon_params
    { icon_emoji: ':shipit:' }
  end

  def post(message)
    params = { text: message, username: username }.merge(icon_params)
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
    "Hey #{assignee_mentions}, it's your turn to take out the trash."
  end

  def afternoon_message
    "Hey #{assignee_mentions}, did you remember to take out the trash?"
  end
end

class RecyclingChore < Chore
  def morning_message
    "Hey #{assignee_mentions}, it's your turn to take out the recycling."
  end

  def afternoon_message
    "Hey #{assignee_mentions}, did you remember to take out the recycling?"
  end
end

class PlantChore < Chore
  attr_reader :name, :heading, :image_path

  def initialize(scheduling:, members:, n_assignees: 1, offset: 0, name:, heading:, image_path:)
    @name = name
    @scheduling = scheduling
    @n_assignees = n_assignees
    @offset = offset
    @members = members
    @name = name
    @heading = heading
    @image_path = image_path
  end

  def icon_params
    { icon_url: "#{PLANT_IMG_URL}/#{image_path}" }
  end

  def username
    name
  end

  def morning_message
    "Hey #{assignee_mentions}, could you please water me today? <#{PLANT_DOC_URL}#heading=#{heading}|Instructions here!>"
  end

  def afternoon_message
    "Hey #{assignee_mentions}, did you remember to water me today? <#{PLANT_URL}#heading=#{heading}|Instructions here!>"
  end
end

class DishChore < Chore
  def morning_message
    "Hey #{assignee_mentions}, you're on dishes today."
  end

  def afternoon_message
    "Hey #{assignee_mentions}, hopefully everyone else has done their dishes so you don't have to!"
  end
end
