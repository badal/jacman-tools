#!/usr/bin/env ruby
# encoding: utf-8

# File: notifier_qt.rb
# Created: 13/12/14
#
# (c) Michel Demazure <michel@demazure.com>

require_relative('version.rb')
require_relative('base.rb')
require_relative('elements/notifier_central_widget.rb')

JacintheManagement.open_log('notifier.log')
JacintheManagement.log('Opening notifier')
central_class = JacintheManagement::GuiQt::NotifierCentralWidget
JacintheManagement::GuiQt::CommonMain.run(central_class)
JacintheManagement.log('Closing notifier')
