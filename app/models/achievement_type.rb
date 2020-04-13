class AchievementType
  def initialize(name, has_param)
    @name = name
    @has_param = has_param
    freeze
  end

  attr_reader :name

  def has_param?
    @has_param
  end

  ALL = [
    AchievementType.new(:fake, false)
  ].freeze
  BY_NAME = ALL.map { |a| [a.name, a] }.to_h.freeze
end
