require_relative './base_chore'

class PlantChore < BaseChore
  attr_reader :name, :heading, :image_path

  def initialize(scheduling:, roster:, n_assignees: 1, offset: 0, name:, heading:, image_path:)
    @name = name
    @scheduling = scheduling
    @n_assignees = n_assignees
    @offset = offset
    @roster = roster
    @name = name
    @heading = heading
    @image_path = image_path
  end

  def icon_params
    { icon_url: "#{ENV['PLANT_IMG_URL']}/#{image_path}", username: name }
  end

  def morning_message
    "Hello #{assignee_mentions}, could you please water me today? <#{ENV['PLANT_DOC_URL']}#heading=#{heading}|Instructions here!>"
  end

  def afternoon_message
    "Hey #{assignee_mentions}, did you remember to water me today? <#{ENV['PLANT_DOC_URL']}#heading=#{heading}|Instructions here!>"
  end
end
