module Roster
  def member_names
    1.upto(9).collect {|i| { member: "Member #{i}", assigned: false } }
  end
end
