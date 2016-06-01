require_relative './base_scheduling'

# Example:
#   MonthlyScheduling.new([1, 15]) will schedule tasks for the 1st and 15th of each month
class MonthlyScheduling < BaseScheduling
  attr_reader :days

  def initialize(days = [1])
    @days = days

    days.each do |d|
      raise ArgumentError, 'must pass integer <= 31' unless d.is_a?(Fixnum) && d <= 31
    end
  end

  def run_on?(date)
    days.include?(date.day)
  end

  def run_index_on(date)
    date.months_since_zero * days.length + days.index(date.day)
  end
end
