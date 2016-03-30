class Event < ActiveRecord::Base
  validates :slug, uniqueness: true, length: { in: 3..10 }, presence: true

  has_many :proposals
  has_many :questions, through: :blinds
  has_many :responses, through: :proposals
  has_many :blinds, -> { order("position ASC") }

  scope :active,    -> { where('active = ? AND (expires_at is NULL OR ? <= expires_at)', true, Time.now) }
  scope :expired,   -> { where('? > expires_at', Time.now) }
  scope :inactive,  -> { where(active: false) }

  def expired?
    expires_at && expires_at.past?
  end

  def is_a_human?(key)
    key.downcase.gsub(/'"/, '').strip == human_key
  end

  # overload method to give the slug instead of the id if its present
  # this make our routes easier to deal with since built in methods like
  # `resources` and `link_to` will just work
  def to_param
    slug || id
  end
end
