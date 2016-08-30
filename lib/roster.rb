require 'httparty'

module Roster
  def select_member(roster, index)
    roster_index = index % roster.length
    assigned = roster[roster_index][:assigned]

    while assigned == true do
      roster_index = (roster_index + 1) % roster.length
      assigned = roster[roster_index][:assigned]
    end

    roster[roster_index][:assigned] = true
    roster[roster_index][:member]
  end

  def member_names
    names = []
    HTTParty.get(ENV['SLACK_MEMBERS_URL'])['members'].each do |m|
      next unless m['profile']['email'] =~ /vermonster.com$/
      next if m['deleted']
      next if NO_CHORE_LIST.include?(m['name'])
      names << m['name']
    end
    names.map {|name| { member: name, assigned: false }}
  end
end
