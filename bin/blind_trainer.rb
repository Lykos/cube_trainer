#!/usr/bin/ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'Qt4'
require 'blind_trainer'

app = Qt::Application.new(ARGV)
b = Ui_BlindTrainer.new
w = BlindTrainer.new
b.setup_ui(w)
w.init
w.show
app.exec
