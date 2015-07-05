#!/usr/bin/env ruby
# encoding: utf-8

# File: collective_manager_qt.rb
# Created: 9/6/15
#
# (c) Michel Demazure <michel@demazure.com>

require_relative('version.rb')
require_relative('base.rb')
require_relative('elements/collective_manager_central_widget.rb')

JacintheManagement.open_log('collective_subscriptions.log')
JacintheManagement.log('Opening collective subscriptions manager')
central_class = JacintheManagement::GuiQt::CollectiveManagerCentralWidget
JacintheManagement::GuiQt::CommonMain.run(central_class)
JacintheManagement.log('Closing collective subscriptions manager')
