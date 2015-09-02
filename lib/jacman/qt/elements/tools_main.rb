#!/usr/bin/env ruby
# encoding: utf-8

# File: tools_main.rb
# Created: 02/09/2015
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheManagement
  module GuiQt
    # specific to add return button
    class ToolsMain < CommonMain
      # a new instance
      def initialize(*args)
        super
        extend_status_bar
      end

      # add the return button to the status bar
      def extend_status_bar
        back = Qt::PushButton.new('OUTILS')
        @status.addPermanentWidget(back)
        @status.connect(back, SIGNAL(:clicked)) { back_to_menu }
      end

      # back to the Tools menu
      def back_to_menu
        self.central_widget = ToolsCentralWidget.new
      end
    end
  end
end
