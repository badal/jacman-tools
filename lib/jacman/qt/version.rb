#!/usr/bin/env ruby
# encoding: utf-8
#
# File: version.rb
# Created: 28 June 2013
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  TOOLS_VERSION = '2.1.0'
  COPYRIGHT = "\u00A9 Michel Demazure"
end

puts JacintheManagement::TOOLS_VERSION if __FILE__ == $PROGRAM_NAME
