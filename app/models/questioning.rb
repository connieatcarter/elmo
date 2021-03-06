class Questioning < ActiveRecord::Base
  include FormVersionable

  belongs_to(:form, :inverse_of => :questionings, :counter_cache => true)
  belongs_to(:question, :autosave => true, :inverse_of => :questionings)
  has_many(:answers, :dependent => :destroy, :inverse_of => :questioning)
  has_one(:condition, :autosave => true, :dependent => :destroy, :validate => false, :inverse_of => :questioning)
  has_many(:referring_conditions, :class_name => "Condition", :foreign_key => "ref_qing_id", :dependent => :destroy, :inverse_of => :ref_qing)
  
  before_create(:set_rank)
  after_create(:notify_form_versioning_policy_of_create)
  before_save(:notify_form_versioning_policy_of_update)
  after_destroy(:notify_form_versioning_policy_of_destroy)

  validates_associated(:condition, :message => :invalid_condition)
  
  alias :old_condition= :condition=
  
  accepts_nested_attributes_for(:question)
  
  # clones a set of questionings, including their conditions
  # assumes qings are in order in which they appear on the form
  # does not save qings and conditions, just initializes them
  def self.duplicate(qings)
    # create basic clones and store cleverly
    qid_hash = {}; new_qings = []
    qings.each do |qing|
      # create the basis clone
      new_qing = new(:question_id => qing.question_id, :rank => qing.rank, :required => qing.required, :hidden => qing.hidden)
      # store in the hash (in case it's needed during condition cloning for later qings)
      qid_hash[qing.question_id] = new_qing
      # clone the condition if necessary
      qing.condition.duplicate(new_qing, qid_hash) if qing.condition
      # store in the array
      new_qings << new_qing
    end
    # return the cloned qings
    new_qings
  end
  
  def answer_required?
    required? && question.qtype.name != "select_multiple"
  end
  
  def published?
    form.published?
  end
  
  # returns any forms other than this one on which this questionings question appears
  def other_forms
    question.forms.reject{|f| f == form}
  end
  
  def method_missing(*args)
    # pass appropriate methods on to question
    if is_question_method?(args[0].to_s)
      question.send(*args)
    else
      super
    end
  end
 
  def respond_to?(symbol, *)
    is_question_method?(symbol.to_s) || super
  end
 
  def respond_to_missing?(symbol, include_private)
    is_question_method?(symbol.to_s) || super
  end
  
  def is_question_method?(symbol)
    symbol.match(/^((name|hint)_([a-z]{2})(=?)|code=?|option_set_id=?|qtype_name=?)(_before_type_cast)?$/)
  end
  
  def has_condition?; !condition.nil?; end
  
  def condition=(c)
    return old_condition=(c) unless c.is_a?(Hash)
    # if all attribs are blank, destroy the condition if it exists
    if c.reject{|k,v| v.blank?}.empty?
      condition.destroy if condition
    # otherwise, set the attribs or build a new condition if none exists
    else
      condition ? condition.attributes = c : build_condition(c.merge(:questioning => self))
    end
  end
  
  def odk_constraint
    exps = []
    exps << ". #{question.minstrictly ? '>' : '>='} #{question.minimum}" if question.minimum
    exps << ". #{question.maxstrictly ? '<' : '<='} #{question.maximum}" if question.maximum
    "(" + exps.join(" and ") + ")"
  end
  
  def previous_qings
    form.questionings.reject{|q| !rank.nil? && (q == self || q.rank > rank)}
  end
  
  def verify_condition_ordering
    condition.verify_ordering if condition
  end
  
  def check_assoc
    raise DeletionError.new(:cant_delete_if_has_answers) unless answers.empty?
  end
  
  private
    def set_rank
      self.rank = form.max_rank + 1 if rank.nil?
      return true
    end
end
