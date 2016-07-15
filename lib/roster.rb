require 'httparty'

module Roster
  def select_member(roster, index)
    roster.delete(roster[index % roster.length])
  end

  def member_names
    names = []
    HTTParty.get(ENV['SLACK_MEMBERS_URL'])['members'].each do |m|
      next unless m['profile']['email'] =~ /vermonster.com$/
      next if m['deleted']
      next if NO_CHORE_LIST.include?(m['name'])
      names << m['name']
    end
    names
  end
end
