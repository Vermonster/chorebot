require 'date'

class Date
  def self.zero
    Date.parse('0000-01-01')
  end

  def days_since_zero
    (self - self.class.zero).to_i
  end

  def weeks_since_zero
    cweek + 52 * year
  end

  def months_since_zero
    month + 12 * year
  end

  def weekend?
    saturday? || sunday?
  end

  def weekday?
    !weekend?
  end
end

class Scheduling
  def run_today?
    today = Date.today
    yesterday = today.prev_day
    day_before = yesterday.prev_day
    return false if today.weekend?
    return true if run_on?(today)
    return true if run_on?(yesterday) && yesterday.weekend?
    return true if run_on?(day_before) && yesterday.weekend? && day_before.weekend?
    false
  end

  def run_index
    run_index_on(Date.today)
  end

  def run_on?(date)
    raise NotImplementedError, "Should return true when it's time"
  end

  def run_index_on(date)
    raise NotImplementedError, "Should increase by one every time run_today? is true"
  end

  def next_run_date
    date = Date.today
    until run_on?(date)
      date = date.next_day
    end
    date
  end
end

# Example:
#   MonthlyScheduling.new([1, 15]) will schedule tasks for the 1st and 15th of each month
class MonthlyScheduling < Scheduling
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

# Example:
#   WeeklyScheduling.new([:monday, :wednesday, :friday]) will schedule tasks every MWF
class WeeklyScheduling < Scheduling
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

class DailyScheduling < WeeklyScheduling
  def initialize
    @days = [:monday, :tuesday, :wednesday, :thursday, :friday]
  end
end

# Example:
#   EveryNDaysScheduling.new(10) will schedule tasks every 10 or so days
class EveryNDaysScheduling < Scheduling
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
