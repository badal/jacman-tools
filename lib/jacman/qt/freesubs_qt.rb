#!/usr/bin/env ruby
# encoding: utf-8

# File: freesubs_qt.rb
# Created: 9/7/15
#
# (c) Michel Demazure <michel@demazure.com>

require_relative('version.rb')
require_relative('elements/freesubs_central_widget.rb')

JacintheManagement.open_log('freesubs.log')
JacintheManagement.log('Opening free subs manager')
central_class = JacintheManagement::GuiQt::FreesubsCentralWidget
JacintheManagement::GuiQt::CommonMain.run(central_class)
JacintheManagement.log('Closing free subs manager')
