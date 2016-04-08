require 'rspec'
require 'pry'
require_relative '../chorebot'

describe 'ChoreBot' do
  it 'has logic to fairly pick N members each weekday, cycling through everyone' do
    members = %w(alice bob caroline david eleanor frank)

    # start with day 1 to make the test clearer
    first_monday = Date.new(2014, 12, 29)
    expect(first_monday).to be_monday
    expect(first_monday.cweek).to eq 1

    expect(assignees_for(first_monday,          members, 1)).to eq ['alice']
    expect(assignees_for(first_monday.next_day, members, 1)).to eq ['bob']

    expect(assignees_for(first_monday,          members, 2)).to eq ['alice', 'bob']
    expect(assignees_for(first_monday.next_day, members, 2)).to eq ['caroline', 'david']

    expect(assignees_for(first_monday,          members, 4)).to eq %w(alice bob caroline david)
    expect(assignees_for(first_monday.next_day, members, 4)).to eq %w(eleanor frank alice bob)
  end
end

def indexes_and_dates_for(scheduling, iterations = 1000)
  date = Date.today
  indexes = []
  dates = []
  iterations.times do
    if scheduling.run_on?(date)
      indexes << scheduling.index_on(date)
      dates << date
    end
    date = date.next_day
  end
  return [indexes, dates]
end

describe MonthlyScheduling do
  it 'increments index once every time run_today? is true' do
    indexes, dates = indexes_and_dates_for(MonthlyScheduling.new)

    indexes.each_with_index do |index, i|
      expect(index).to eq indexes[0] + i
    end

    dates.each_with_index do |date, i|
      expect(date.month % 12).to eq (dates[0].month + i) % 12
      expect([1, 2, 3]).to include date.day
    end
  end
end

describe EveryNDaysScheduling do
  it 'increments index once every time run_today? is true' do
    indexes, dates = indexes_and_dates_for(EveryNDaysScheduling.new(10))

    indexes.each_with_index do |index, i|
      expect(index).to eq indexes[0] + i
    end

    dates[1..-1].each.with_index(1) do |date, i|
      expect([8, 9, 10, 11, 12]).to include((date - dates[i-1]).to_i)
    end
  end
end

describe WeeklyScheduling do
  it 'increments index once every time run_today? is true' do
    indexes, dates = indexes_and_dates_for(WeeklyScheduling.new)

    indexes.each_with_index do |index, i|
      expect(index).to eq indexes[0] + i
    end

    dates[1..-1].each.with_index(1) do |date, i|
      expect([1,-51]).to include(date.cweek - dates[i-1].cweek)
    end
  end
end
