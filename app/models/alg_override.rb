class AlgOverride < ApplicationRecord
  include AlgLike

  belongs_to :mode

  alias owning_set mode
end
