# == Schema Information
#
# Table name: users
#
#  id            :integer          not null, primary key
#  email         :string(255)      not null
#  password      :string(255)      not null
#  name          :string(255)      not null
#  access_token  :string(255)
#  refresh_token :string(255)
#  expires_in    :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class User < ActiveRecord::Base
end
