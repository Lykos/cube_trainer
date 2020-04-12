# The part of the result that is directly dependent on the performance of the user.
# Forms a result together with the input, i.e. the information which case the user solved.
class PartialResult
  include ActiveModel::Model
  attr_accessor :time_s, :failed_attempts, :word, :success, :num_hints
end
