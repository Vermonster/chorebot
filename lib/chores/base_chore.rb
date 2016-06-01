class BaseChore
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
