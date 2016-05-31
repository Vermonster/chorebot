require_relative './base_chore'

class RecyclingChore < BaseChore
  def morning_message
    "Hey #{assignee_mentions}, you're on recycling."
  end

  def afternoon_message
    "Hey #{assignee_mentions}, just a reminder to take out the recycling (bags out after 5)."
  end
end
