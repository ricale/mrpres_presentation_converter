# == Schema Information
#
# Table name: presentations
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Presentation < ActiveRecord::Base
  has_one :converted_presentation

  validates_presence_of :user_id
  validates_presence_of :title

  before_validation :default_values

  def default_values
    self.user_id = 1
  end
end
