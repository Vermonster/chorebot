require 'date'

class Scheduling
  attr_reader :offset

  def initialize(offset = 0)
    @offset = offset
  end

  def weekday?(day)
    !day.saturday? && !day.sunday?
  end

  def run_today?
    run_on?(Date.today)
  end

  def next_index
    index_on(Date.today)
  end

  def days_until_next_watering
    i = 0
    d = Date.today
    until run_on?(d)
      i += 1
      d = d.next_day
    end
    i
  end

  def run_on?(d)
    raise NotImplementedError, "Should return true when it's time"
  end

  def index_on(d)
    raise NotImplementedError, "Should increase by one every time run_today? is true"
  end
end

class MonthlyScheduling < Scheduling
  def index_on(d)
    offset + d.month + 12*(d.year - 2000)
  end

  def run_on?(d)
    return false unless weekday?(d)
    return true if d.day == 1
    return true if d.day == 2 && !weekday?(d.prev_day)
    return true if d.day == 3 && !weekday?(d.prev_day) && !weekday?(d.prev_day.prev_day)
    false
  end
end

class EveryNDaysScheduling < Scheduling
  attr_reader :n

  def initialize(n, offset = 0)
    super(offset)
    @n = n
  end

  def run_on?(d)
    d1 = d.prev_day
    d2 = d.prev_day.prev_day
    return false unless weekday?(d)
    return true if theoretically_run_on?(d)
    return true if theoretically_run_on?(d1) && !weekday?(d1)
    return true if theoretically_run_on?(d2) && !weekday?(d1) && !weekday?(d2)
  end

  def theoretically_run_on?(d)
    (d - Date.parse('2000-01-01')) % n == 0
  end

  def index_on(d)
    offset + ((d - Date.parse('2000-01-01')) / n).to_i
  end
end

class WeeklyScheduling < EveryNDaysScheduling
  def initialize(offset = 0)
    @offset = offset
    @n = 7
  end
end

def monthly(offset=0)
  MonthlyScheduling.new(offset)
end

def every_n_days(n, offset=0)
  EveryNDaysScheduling.new(n, offset)
end

def weekly(offset=0)
  WeeklyScheduling.new(offset)
end

PLANTS = {
  bertha: {
    name: 'Bertha',
    heading: 'h.sl24hns7ta7c',
    image_path: "bertha.jpg",
    scheduling: monthly
  },
  edward: {
    name: 'Edward',
    heading: 'h.wlvxy5bc7z7d',
    image_path: "edward.jpg",
    scheduling: monthly(1)
  },
  lula: {
    name: 'Lula',
    heading: 'h.nvlbm0zacdtz',
    image_path: "lula.jpg",
    scheduling: monthly(2)
  },
  chester: {
    name: 'Chester',
    heading: 'h.7ymknjojnom7',
    image_path: 'chester.jpg',
    scheduling: every_n_days(20)
  },
  myrtle: {
    name: 'Myrtle',
    heading: 'h.2lttmnmb2ozt',
    image_path: 'myrtle.png',
    scheduling: weekly(1)
  },
  maud_frank_and_henri: {
    name: 'Maud, Frank, and Henri',
    heading: 'h.pzcfgmk69r6q',
    image_path: 'maud_frank_and_henri.png',
    scheduling: monthly(3)
  }
}
