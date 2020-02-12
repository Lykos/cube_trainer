#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'Qt4'
require 'cube_trainer/blind_trainer'

include CubeTrainer

app = Qt::Application.new(ARGV)
b = Ui_BlindTrainer.new
w = BlindTrainer.new
b.setup_ui(w)
w.init
w.show
app.exec
