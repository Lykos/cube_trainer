# frozen_string_literal: true

require 'cube_trainer/buffer_helper'
require 'cube_trainer/training/commutator_sets'
require 'cube_trainer/training/commutator_options'
require 'cube_trainer/training/results_model'
require 'cube_trainer/training/stats_computer'
require 'cube_trainer/training/trainer'
require 'etc'

options = CubeTrainer::Training::CommutatorOptions.parse(ARGV)
ActiveRecord::Base.connected_to(database: :primary) do
  user = User.where(name: OsHelper.os_user).first_or_create!(
    password: OsHelper.default_password,
    password_confirmation: OsHelper.default_password
  )
  mode = user.modes.find(name: options.mode_name)
  results_model = CubeTrainer::Training::ResultsModel.new(mode)
  generator = options.commutator_info.generator_class.new(options)
  hinter = generator.hinter
  learner = options.commutator_info.learner_class.new(hinter, results_model, options)
  stats_computer = CubeTrainer::Training::StatsComputer.new(Time.zone.now, options)

  if generator.input_items
    stats = stats_computer.input_stats(generator.input_items)
    puts "#{stats[:found]} of #{stats[:total]} items found, #{stats[:newish_elements]} of them " \
         "newish, #{stats[:missing]} missing."
    puts "#{stats_computer.num_results} results, #{stats_computer.num_recent_results} of them in " \
         'the last 24 hours.'
  end

  input_sampler = generator.input_sampler(results_model)
  CubeTrainer::Training::Trainer.new(learner, results_model, input_sampler).run
end
