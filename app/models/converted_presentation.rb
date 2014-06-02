# == Schema Information
#
# Table name: converted_presentations
#
#  id              :integer          not null, primary key
#  presentation_id :integer          not null
#  file_name       :string(255)      not null
#  total_pages     :integer          default(0)
#  status          :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class ConvertedPresentation < ActiveRecord::Base
  belongs_to :presentation

  validates_presence_of :presentation_id
  validates_presence_of :file_name
  validates_presence_of :total_pages

  before_validation :default_values

  after_validation :local_timezone_on_create, on: :create
  after_validation :local_timezone_on_update, on: :update

  after_save :default_timezone

  CONVERTING = 0
  COMPLETE   = 1
  FAILED     = 2

  def default_values
    self.status ||= ConvertedPresentation::CONVERTING
  end

  def local_timezone_on_create
    ConvertedPresentation.record_timestamps = false
    self.created_at = Time.now.utc + 9.hours
    puts self.created_at
  end

  def local_timezone_on_update
    ConvertedPresentation.record_timestamps = false
    self.updated_at = Time.now.utc + 9.hours
    puts self.updated_at
  end

  def default_timezone
    ConvertedPresentation.record_timestamps = true
  end
end
