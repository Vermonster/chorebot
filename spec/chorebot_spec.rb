require 'rspec'
require 'pry'
require_relative '../chorebot'

def indexes_and_dates_for(scheduling, iterations = 1000)
  date = Date.today
  indexes = []
  dates = []
  iterations.times do
    if scheduling.run_on?(date)
      indexes << scheduling.run_index_on(date)
      dates << date
    end
    date = date.next_day
  end
  return [indexes, dates]
end

shared_examples_for 'a scheduling object' do
  it 'increments run_index by 1 every time run_today? is true' do
    indexes, dates = indexes_and_dates_for(scheduling)
    indexes.each_with_index do |index, i|
      expect(index).to eq indexes[0] + i
    end
  end
end

describe MonthlyScheduling do
  it_behaves_like 'a scheduling object' do
    let(:scheduling) { MonthlyScheduling.new([1]) }
  end

  it_behaves_like 'a scheduling object' do
    let(:scheduling) { MonthlyScheduling.new([2, 15]) }
  end

  it 'picks dates every month, with a max of 2 days difference' do
    indexes, dates = indexes_and_dates_for(MonthlyScheduling.new([1]))

    dates.each_with_index do |date, i|
      expect(date.month % 12).to eq (dates[0].month + i) % 12
      expect([1, 2, 3]).to include date.day
    end
  end

  it 'picks dates every month, with a max of 2 days difference' do
    indexes, dates = indexes_and_dates_for(MonthlyScheduling.new([5, 12]))

    dates.each_with_index do |date, i|
      expect(date.month % 12).to eq (dates[0].month + i/2) % 12
      expect([5, 6, 7, 12, 13, 14]).to include date.day
    end
  end
end

describe EveryNDaysScheduling do
  it_behaves_like 'a scheduling object' do
    let(:scheduling) { EveryNDaysScheduling.new(8) }
  end

  it 'picks dates every N (plus or minus 2) days' do
    indexes, dates = indexes_and_dates_for(EveryNDaysScheduling.new(10))

    dates[1..-1].each.with_index(1) do |date, i|
      expect([8, 9, 10, 11, 12]).to include((date - dates[i-1]).to_i)
    end
  end
end

describe WeeklyScheduling do
  it_behaves_like 'a scheduling object' do
    let(:scheduling) { WeeklyScheduling.new([:wednesday]) }
  end

  it_behaves_like 'a scheduling object' do
    let(:scheduling) { WeeklyScheduling.new([:tuesday, :thursday]) }
  end

  it 'picks dates once per week' do
    indexes, dates = indexes_and_dates_for(WeeklyScheduling.new([:thursday]))

    dates[1..-1].each.with_index(1) do |date, i|
      expect(date).to be_thursday
      expect([1,-51]).to include(date.cweek - dates[i-1].cweek)
    end
  end

  it 'picks alternating weekdays' do
    indexes, dates = indexes_and_dates_for(WeeklyScheduling.new([:monday, :wednesday, :friday]))

    dates[1..-1].each.with_index(1) do |date, i|
      prev = dates[i-1]
      if prev.monday?
        expect(date).to be_wednesday
        expect(date.cweek).to eq prev.cweek
      elsif prev.wednesday?
        expect(date).to be_friday
        expect(date.cweek).to eq prev.cweek
      elsif prev.friday?
        expect(date).to be_monday
        expect([1,-51]).to include(date.cweek - prev.cweek)
      end
    end
  end
end

describe "Assigning team members to chores" do
  module Roster
    def member_names
      1.upto(10).collect {|i| { member: "Member #{i}", assigned: false } }
    end
  end

  it "should not assign the same member to multiple chores" do
    assignees = chores.select(&:run_today?).collect(&:assignees).flatten
    remaining_roster = chores.select(&:run_today?).each(&:assignees).last.class.class_variable_get(:@@roster)

    expect(assignees - remaining_roster).to eq assignees
  end
end
