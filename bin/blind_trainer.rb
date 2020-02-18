#!/usr/bin/ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'Qt4'
require 'cube_trainer/ui/blind_trainer'

app = Qt::Application.new(ARGV)
b = Ui_BlindTrainer.new
w = CubeTrainer::Ui::BlindTrainer.new
b.setup_ui(w)
w.init
w.show
app.exec
