# == Schema Information
#
# Table name: converted_presentations
#
#  id              :integer          not null, primary key
#  presentation_id :integer
#  file_name       :string(255)
#  pages           :integer
#  created_at      :datetime
#  updated_at      :datetime
#  status          :integer
#

class ConvertedPresentation < ActiveRecord::Base
  belongs_to :presentation

  validates_presence_of :presentation_id
  validates_presence_of :file_name
  validates_presence_of :pages

  before_validation :default_values

  CONVERTING = 0
  COMPLETE   = 1
  FAILED     = 2

  def default_values
    self.status ||= ConvertedPresentation::CONVERTING
  end
end
