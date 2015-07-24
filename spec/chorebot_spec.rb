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
