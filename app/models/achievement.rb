class Achievement
  include ActiveModel::Model
  attr_accessor :key, :name, :description

  validates :key, presence: true
  validates :name, presence: true

  def to_simple
    {
      key: key,
      name: name,
      description: description
    }
  end

  ALL = [
    Achievement.new(key: :fake, name: 'Fake', description: 'Fake achievement for tests.')
  ].freeze
  ALL.each(&:validate!)
  BY_KEY = ALL.map { |a| [a.key, a] }.to_h.freeze

  def self.find_by_key(key)
    BY_KEY[key.to_sym]
  end
end
