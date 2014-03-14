class Presentation < ActiveRecord::Base
  has_one :converted_presentation

  validates_presence_of :user_id
  validates_presence_of :title

  before_validation :default_values

  def default_values
    self.user_id = 1
  end
end
