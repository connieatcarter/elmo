class RemoveTimestampQuestions < ActiveRecord::Migration
  def self.up
    if @qt = QuestionType.find_by_name("start_timestamp")
      @qs = Question.find_all_by_question_type_id(@qt.id)
      @qs.each{|q| q.answers.each{|a| a.destroy}; q.questionings.each{|qing| qing.destroy}; Question.find(q.id).destroy}
      
    end
  end

  def self.down
  end
end
