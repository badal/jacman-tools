#!/usr/bin/env ruby
# encoding: utf-8
#
# File: version.rb
# Created: 28 June 2013
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  MAJOR = 3
  MINOR = 2
  TINY = 1

  VERSION = [MAJOR, MINOR, TINY].join('.').freeze

  COPYRIGHT = "\u00A9 Michel Demazure"
end

puts JacintheManagement::VERSION if __FILE__ == $PROGRAM_NAME
