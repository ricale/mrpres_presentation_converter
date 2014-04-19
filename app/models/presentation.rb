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
end
