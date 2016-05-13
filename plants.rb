require_relative './lib/scheduling'

class OffsetScheduling
  attr_reader :offset, :scheduling

  def initialize(scheduling, offset = 0)
    @offset = offset
    @scheduling = scheduling
  end

  def run_today?
    scheduling.run_today?
  end

  def run_index
    scheduling.run_index + offset
  end
end

def monthly(offset=0)
  OffsetScheduling.new(MonthlyScheduling.new(1), offset)
end

def every_n_days(n, offset=0)
  OffsetScheduling.new(EveryNDaysScheduling.new(n), offset)
end

def weekly(offset=0)
  OffsetScheduling.new(WeeklyScheduling.new(:monday), offset)
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
