class ChangeUserToMeetMobiSso < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.integer :sso_id
      t.integer :stu_id
      t.string :name
      t.string :nickname
      t.index :sso_id
      t.index :stu_id
    end
  end
end
