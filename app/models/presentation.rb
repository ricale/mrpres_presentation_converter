# == Schema Information
#
# Table name: presentations
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  title       :string(255)      not null
#  description :text
#  status      :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Presentation < ActiveRecord::Base
  has_one :converted_presentation

  CONVERTING = 0
  COMPLETE   = 1
  FAILED     = 2

  after_validation :local_timezone_on_create, on: :create
  after_validation :local_timezone_on_update, on: :update

  after_save :default_timezone

  def local_timezone_on_create
    Presentation.record_timestamps = false
    self.created_at = Time.now.utc + 9.hours
    puts self.created_at
  end

  def local_timezone_on_update
    Presentation.record_timestamps = false
    self.updated_at = Time.now.utc + 9.hours
    puts self.updated_at
  end

  def default_timezone
    Presentation.record_timestamps = true
  end
end
