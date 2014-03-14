class ConvertedPresentation < ActiveRecord::Base
  belongs_to :presentation

  validates_presence_of :presentation_id
  validates_presence_of :file_name
  validates_presence_of :pages
end
