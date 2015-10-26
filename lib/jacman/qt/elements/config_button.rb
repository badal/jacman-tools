#!/usr/bin/env ruby
# encoding: utf-8

# File: config_button.rb
# Created: 18/10/2015
#
# (c) Michel Demazure <michel@demazure.com>
module JacintheManagement
  module GuiQt
    module ConfigButton
      # add a button in an added horizontal layout box
      # @return [Qt::PushButton] added button
      def add_config_button
        box = Qt::HBoxLayout.new
        add_layout(box)
        button = Qt::PushButton.new('Changer le mode')
        box.add_widget(button)
        box.addStretch
        button
      end
    end
  end
end
