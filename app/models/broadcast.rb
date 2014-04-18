# == Schema Information
#
# Table name: broadcasts
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  presentation_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#

class Broadcast < ActiveRecord::Base
end
