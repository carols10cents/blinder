class AddScoreToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :score, :decimal
  end
end
