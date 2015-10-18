#!/usr/bin/env ruby
# encoding: utf-8
#
# File: version.rb
# Created: 28 June 2013
#
# (c) Michel Demazure & Kenji Lefevre

module JacintheManagement
  module GuiQt
    TOOLS_VERSION = '2.5.1'
    COPYRIGHT = "\u00A9 Michel Demazure"

    def self.tools_versions(specific)
      ['Versions :',
       "   jacman-qtbase : #{JacintheManagement::GuiQt::BASE_VERSION}",
       "   jacman-utils : #{JacintheManagement::Utils::VERSION}"
      ] + specific +
        ['S.M.F. 2014-2015',
         "\u00A9 Michel Demazure, LICENCE M.I.T."]
    end
  end
end

puts JacintheManagement::GuiQt::TOOLS_VERSION if __FILE__ == $PROGRAM_NAME
