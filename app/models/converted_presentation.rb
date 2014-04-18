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

  CONVERTING = 0
  COMPLETE   = 1
  FAILED     = 2

  def default_values
    self.status ||= ConvertedPresentation::CONVERTING
  end
end
