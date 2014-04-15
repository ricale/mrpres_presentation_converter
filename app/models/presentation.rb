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
end
