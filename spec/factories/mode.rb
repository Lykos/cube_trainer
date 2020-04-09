FactoryBot.define do
  factory :mode do
    name { mode }
    show_input_mode { :name }
    mode_type { :floating_2flips }
    goal_badness { 1.0 }
    cube_size { 3 }
    user
  end
end
