require 'rspec'
require 'pry'
require_relative '../chorebot'


def member_names
  %w(1 2 3 4 5 6 7)
end

describe 'ChoreBot' do
  it '.assignees_for' do
    expect(assignees_for(Date.new(2015, 6, 1), member_names)).to eq %w(4 5 6)
    expect(assignees_for(Date.new(2015, 6, 2), member_names)).to eq %w(7 1 2)
    expect(assignees_for(Date.new(2015, 6, 3), member_names)).to eq %w(3 4 5)
    expect(assignees_for(Date.new(2015, 6, 4), member_names)).to eq %w(6 7 1)
  end

  it '.assign_chore' do
    expect(assign_chores(Date.new(2015,7,1)).values.to_s).to include "7", "1", "2"
    expect(assign_chores(Date.new(2015,7,2)).values.to_s).to include "3", "4", "5"
    expect(assign_chores(Date.new(2015,7,3)).values.to_s).to include "6", "7", "1"
  end

end
