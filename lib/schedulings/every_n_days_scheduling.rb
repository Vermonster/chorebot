require_relative './base_scheduling'

# Example:
#   EveryNDaysScheduling.new(10) will schedule tasks every 10 or so days
class EveryNDaysScheduling < BaseScheduling
  attr_reader :n, :offset

  def initialize(n, offset = 0)
    @n = n
    @offset = offset
  end

  def run_index_on(date)
    (offset + date.days_since_zero) / n
  end

  def run_on?(date)
    (offset + date.days_since_zero) % n == 0
  end
end
