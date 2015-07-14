#!/usr/bin/env ruby
# encoding: utf-8

# File: tools.rb
# Created: 13/7/15
#
# (c) Michel Demazure <michel@demazure.com>
require 'jacman/utils'
require 'jacman/qt/base'
require_relative 'elements/tools_central_widget'

JacintheManagement.open_log('tools.log')
JacintheManagement.log('Opening tools manager')
central_class = JacintheManagement::GuiQt::ToolsCentralWidget
JacintheManagement::GuiQt::CommonMain.run(central_class)
JacintheManagement.log('closing tools manager')
