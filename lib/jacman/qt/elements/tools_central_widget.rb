#!/usr/bin/env ruby
# encoding: utf-8

# File: tools_central_widget.rb
# Created: 13 uly 2015
#
# (c) Michel Demazure <michel@demazure.com>

# Jacinthe Management
module JacintheManagement
  module GuiQt
    # Central widget for tools choice
    class ToolsCentralWidget < CentralWidget
      # "About" message
      ABOUT = ['Versions :',
               "   jacman-qtbase : #{JacintheManagement::GuiQt::BASE_VERSION}",
               "   jacman-utils : #{JacintheManagement::Utils::VERSION}",
               'S.M.F. 2015',
               "\u00A9 Michel Demazure, LICENCE M.I.T."]

      SIGNAL_EDITING_FINISHED = SIGNAL('editingFinished()')
      SIGNAL_CLICKED = SIGNAL(:clicked)

      # @return [[Integer] * 4] geometry of mother window
      def geometry
        if Utils.on_mac?
          [100, 100, 600, 650]
        else
          [100, 100, 400, 500]
        end
      end

      # @return [String] name of manager specialty
      def subtitle
        'Outils de management de Jacinthe'
      end

      # @return [Array<String>] about message
      def about
        [subtitle] + ABOUT
      end

      # WARNING: overrides the common one, useless in this case
      def update_values
      end

      # Slot: open the help file
      def help
        # url = Qt::Url.new("file:///#{Coll::HELP_FILE}")
        # Qt::DesktopServices.openUrl(url)
      end

      def add_call(text, command)
        button = Qt::PushButton.new(text)
        button.minimum_height = 60
        add_widget(button)
        connect(button, SIGNAL_CLICKED) { command.call }
      end

      def build_layout
        add_call('Notification des abonnements électroniques', ->() { notifier })
        add_call('Gestion des abonnements gratuits', ->() { freesubs })
        add_call('Création d\'un abonnements collectif', ->() { collective_exploitation })
        add_call('Exploitation des abonnements collectifs', ->() { collective_exploitation })
        add_call('Fichiers de requête', ->() { sql_files })
        @layout.add_stretch
      end

      def notifier
        require 'jacman/notifications'
        require_relative 'notifier_central_widget'
        parent.central_widget = NotifierCentralWidget.new
      end

      def freesubs
        require 'jacman/freesubs'
        require_relative 'freesubs_central_widget'
        parent.central_widget = FreesubsCentralWidget.new
      end

      def collective_manager
        require 'jacman/coll'
        require_relative 'collective_manager_central_widget'
        parent.central_widget = CollectiveManagerCentralWidget.new
      end

      def collective_exploitation
        require 'jacman/coll'
        require_relative 'collective_exploitation_central_widget'
        parent.central_widget = CollectiveExploitationCentralWidget.new
      end

      def sql_files
        require_relative 'sql_manager_central_widget'
        parent.central_widget = SqlManagerCentralWidget.new
      end
    end
  end
end