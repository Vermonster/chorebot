require_relative './weekly_scheduling'

class DailyScheduling < WeeklyScheduling
  def initialize
    @days = [:monday, :tuesday, :wednesday, :thursday, :friday]
  end
end
