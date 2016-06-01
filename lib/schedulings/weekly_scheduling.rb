require_relative './base_scheduling'

# Example:
#   WeeklyScheduling.new([:monday, :wednesday, :friday]) will schedule tasks every MWF
class WeeklyScheduling < BaseScheduling
  attr_reader :days

  def initialize(days = [:monday])
    @days = days

    days.each do |d|
      raise ArgumentError, 'must pass day name' unless Date::DAYNAMES.any? { |name| name.downcase == d.to_s }
    end
  end

  def run_on?(date)
    days.any? { |d| date.send("#{d}?") }
  end

  def run_index_on(date)
    date.weeks_since_zero * days.length + days.index { |d| date.send("#{d}?") }
  end
end
