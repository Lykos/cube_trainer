class Case
  include ActiveModel::Model

  belongs_to :mode
  has_many :result
  validates :id, presence: true
  attribute :representation, :representation
  validates :representation, presence: true
  validates :mode_id, presence: true

  def to_simple
    {
      id: id,
      representation: mode.maybe_apply_letter_scheme(representation).to_s,
      created_at: mode.created_at
    }
  end
end
