#!/usr/bin/env ruby
# encoding: utf-8
#
# File: version.rb
# Created: 28 June 2013
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  module GuiQt
    TOOLS_VERSION = '2.3.0'
    COPYRIGHT = "\u00A9 Michel Demazure"
  end
end

puts JacintheManagement::GuiQt::TOOLS_VERSION if __FILE__ == $PROGRAM_NAME
