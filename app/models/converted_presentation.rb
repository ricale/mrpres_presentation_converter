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
