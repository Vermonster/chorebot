require_relative './base_chore'

class DishChore < BaseChore
  def morning_message
    "Good morning #{assignee_mentions}, you're on dishes today."
  end

  def afternoon_message
    "Hey everyone, please don't forget to wash your dishes so #{assignee_mentions} won't have to!"
  end
end
