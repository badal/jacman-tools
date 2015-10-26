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
      # "About" specific message
      SPECIFIC = ["   jacman-tools : #{JacintheManagement::GuiQt::TOOLS_VERSION}"]

      # "About message"
      ABOUT = GuiQt.tools_versions(SPECIFIC)

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

      # add button and connect command
      # @param [String] text text for button
      # @param [Proc] command command for button
      def add_call(text, command)
        button = Qt::PushButton.new(text)
        button.minimum_height = 50
        add_widget(button)
        connect(button, SIGNAL_CLICKED) { command.call }
      end

      # build the layout
      # FLOG: 28.6
      def build_layout
        year = Time.now.year
        add_call('Notification des abonnements électroniques', ->() { notifier })
        add_call("Extension des abonnements gratuits de l'année #{year - 1}", ->() { freesubs(year - 1) })
        add_call("Extension des abonnements gratuits de l'année #{year}", ->() { freesubs(year) })
        add_call('Création d\'un abonnement collectif', ->() { collective_manager })
        add_call('Exploitation des abonnements collectifs', ->() { collective_exploitation })
        add_call('Fichiers de requête', ->() { sql_files })
        @layout.add_stretch
      end

      # slot: notifier
      def notifier
        require 'jacman/notifications'
        require_relative 'notifier_central_widget'
        parent.central_widget = NotifierCentralWidget.new
      end

      # slot: freesubs
      # @param [Fixnum] year reference year
      def freesubs(year)
        require 'jacman/freesubs'
        require_relative 'freesubs_central_widget'
        parent.central_widget = FreesubsCentralWidget.new(year)
      end

      # slot: collective manager
      def collective_manager
        require 'jacman/coll'
        require_relative 'collective_manager_central_widget'
        parent.central_widget = CollectiveManagerCentralWidget.new
      end

      # slot: collective exploitation
      def collective_exploitation
        require 'jacman/coll'
        require_relative 'collective_exploitation_central_widget'
        parent.central_widget = CollectiveExploitationCentralWidget.new
      end

      # slot: SQL files manager
      def sql_files
        require_relative 'sql_manager_central_widget'
        parent.central_widget = SqlManagerCentralWidget.new
      end
    end
  end
end
