class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
      t.integer :level
      t.boolean :location_required

      t.timestamps
    end
  end

  def self.down
    drop_table :roles
  end
end
