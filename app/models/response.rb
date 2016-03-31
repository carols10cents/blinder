class Response < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :question
  has_one    :scrub

  validate :required_field?

  def scrubbed_at?(level)
    scrub && scrub.blind_level > level
  end

  protected

  def required_field?
    if question.required? and value.blank?
      errors.add(:base, "<span>#{question.label}</span> is a required field.".html_safe )
    end
  end
end
