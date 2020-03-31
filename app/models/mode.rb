class Mode < ApplicationRecord
  belongs_to :user

  # TODO: Make it configurable
  def letter_scheme
    @letter_scheme ||= BernhardLetterScheme.new
  end

  # TODO: Make it configurable
  def color_scheme
    ColorScheme::BERNHARD
  end
end
