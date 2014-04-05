class AddStatusToConvertedPresentation < ActiveRecord::Migration
  def change
    add_column :converted_presentations, :status, :integer
  end
end
