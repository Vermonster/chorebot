require_relative './base_chore'

class TrashChore < BaseChore
  def morning_message
    "Hi #{assignee_mentions}, it's your turn to take out the trash (bags out after 5pm)."
  end

  def afternoon_message
    "Hi #{assignee_mentions}, did you remember to take out the trash? Remember, bags out after 5pm."
  end
end
