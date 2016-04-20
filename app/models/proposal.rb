require 'digest/sha1'

class Proposal < ActiveRecord::Base
  has_many   :responses, autosave: true
  has_many   :notes, dependent: :destroy
  belongs_to :event

  after_create :generate_slug

  scope :listing,     -> { select(:id, :slug, :updated_at, :created_at) }
  scope :order_submitted, -> { order('created_at ASC') }
  scope :for_event,   -> (event_id) { listing.order_submitted.where(event_id: event_id, safe_for_review: true) }
  scope :unsafe,      -> { listing.order_submitted.where(safe_for_review: false) }
  scope :safe,        -> { listing.order_submitted.where(safe_for_review: true) }

  accepts_nested_attributes_for :responses

  def responses_for(blind)
    question_ids = blind.questions.map &:id
    responses.where(question_id: question_ids).decorate
  end

  def response_for_question(question)
    responses.where(question_id: question.id).first.decorate
  end

  def get_email_address
    # I hate this method.
    # This exposes a fundamental weakness in my approach to this app. In the future,
    # this will need a refactor so that contact information is collected at the proposal level
    # rather than the blind level (or maybe through user accounts).
    q_id = event.questions.where(label: "Email Address").first.id
    responses.where(question_id: q_id).first.value
  end

  def notes_for_user(user)
    notes.where(user: user).first
  end

  protected

  def generate_slug
    seed = self.responses.any? ? self.responses.sample.value : random_seed
    self.slug = Digest::SHA1.hexdigest(Time.now.to_s + seed)
    save!
  end

  def random_seed
    %w(taco _elephant werewolf submarine fern5 trampoline satellite fight! window).sample
  end
end
