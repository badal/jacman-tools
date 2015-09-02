#!/usr/bin/env ruby
# encoding: utf-8

# File: tools.rb
# Created: 13/7/15
#
# (c) Michel Demazure <michel@demazure.com>

require_relative 'version.rb'
require_relative 'elements/tools_central_widget.rb'
require_relative 'elements/tools_main.rb'

JacintheManagement.open_log('tools.log')
JacintheManagement.log('Opening tools manager')
central_class = JacintheManagement::GuiQt::ToolsCentralWidget
JacintheManagement::GuiQt::ToolsMain.run(central_class)
JacintheManagement.log('closing tools manager')
