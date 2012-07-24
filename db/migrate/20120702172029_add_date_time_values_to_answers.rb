class AddDateTimeValuesToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :time_value, :time
    add_column :answers, :date_value, :date
    add_column :answers, :datetime_value, :datetime
  end
end
