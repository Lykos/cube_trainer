#!/usr/bin/ruby

$:.unshift(File.dirname(__FILE__))

require 'Qt4'
require 'blind_trainer_ui'

class BlindTrainer < Qt::MainWindow
  slots 'start_stop_clicked()'
  def start_stop_clicked
    puts 'LOL'
  end
end
