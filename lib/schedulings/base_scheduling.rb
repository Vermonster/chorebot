require_relative '../core_ext/date'

class BaseScheduling
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
