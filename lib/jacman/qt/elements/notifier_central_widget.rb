#!/usr/bin/env ruby
# encoding: utf-8

# File: monitor_central_widget.rb
# Created:  02/10/13 for manager
# Modified: 12/14 for monitor
#
# (c) Michel Demazure <michel@demazure.com>
require_relative('config_button.rb')

# script methods for Jacinthe Management
module JacintheManagement
  module GuiQt
    # Central widget for manager
    class NotifierCentralWidget < CentralWidget
      include ConfigButton
      # version of the notifier
      VERSION = '0.3.0'
      # "About" specific message
      SPECIFIC = [
        "   jacman-notifications : #{JacintheManagement::Notifications::VERSION}",
        "   notifier: #{VERSION}"
      ]
      # "About message"
      ABOUT = GuiQt.tools_versions(SPECIFIC)

      # format for *caption_text*
      FMT = '%3d '

      SIGNAL_CLICKED = SIGNAL(:clicked)

      # @param [Bool] mode whether mails have to be sent
      def initialize(mode = false)
        @mode = mode
        super()
      end

      # @return [[Integer] * 4] geometry of mother window
      def geometry
        if Utils.on_mac?
          [100, 100, 600, 900]
        else
          [100, 100, 400, 620]
        end
      end

      # @return [String] name of manager specialty
      def subtitle
        'Notification des abonnements électroniques'
      end

      # @return [Array<String>] about message
      def about
        [subtitle] + ABOUT
      end

      # build the layout
      def build_layout
        build_first_line
        add_config_area
        build_selection_area
        build_notify_command_area
        add_show_report_button
        build_report_area
        update_selection
        redraw_selection_area
      end

      # add area
      def add_config_area
        button = add_config_button
        connect(button, SIGNAL_CLICKED) do
          new_central_widget = NotifierCentralWidget.new(!@mode)
          parent.central_widget = new_central_widget
        end
      end

      # add area with report button
      def add_show_report_button
        Qt::HBoxLayout.new do |box|
          add_layout(box)
          @show_button = Qt::PushButton.new('Voir le rapport')
          box.add_widget(@show_button)
          @show_button.enabled = false
          connect(@show_button, SIGNAL_CLICKED) { show_report }
          box.add_stretch
          button = Qt::PushButton.new('Modèles')
          box.add_widget(button)
          connect(button, SIGNAL_CLICKED) { open_model_directory }
        end
      end

      # slot : show missed notifiaction report
      def show_report
        Notifications::Registry.show_missed_notifications
      end

      # show th report
      # @param [String] text to show
      def report(text)
        @report.append(text)
      end

      # build the report area
      def build_report_area
        Qt::HBoxLayout.new do |box|
          add_layout(box)
          @report = Qt::TextEdit.new
          box.add_widget(@report)
          @report.append("<b>Mode #{@mode ? 'réel' : 'simulé'}</b>")
        end
      end

      # build the notify button
      def build_notify_command_area
        Qt::HBoxLayout.new do |box|
          add_layout(box)
          @sel = Qt::Label.new
          box.add_widget(@sel)
          @notify_button = Qt::PushButton.new('Notifier ?')
          box.add_widget(@notify_button)
          connect(@notify_button, SIGNAL_CLICKED) { confirm }
        end
      end

      # build the first line
      def build_first_line
        @number = Qt::Label.new
        add_widget(@number)
      end

      # build the selection area
      def build_selection_area
        update_classification
        @check_buttons = []
        @numbers = []
        @pending_notifications.each_pair.with_index do |(key, _), idx|
          line = Qt::HBoxLayout.new
          add_layout(line)
          add_variable_elements(line, idx)
          line.add_widget(Qt::Label.new(format_key(key)))
          line.addStretch
        end
      end

      def add_variable_elements(line, idx)
        @numbers[idx] = Qt::Label.new
        @check_buttons[idx] = Qt::CheckBox.new
        connect(@check_buttons[idx], SIGNAL(:clicked)) { update_selection }
        line.add_widget(@numbers[idx])
        line.add_widget(@check_buttons[idx])
      end

      # WARNING: overrides the common one, useless in this case
      def update_values
      end

      # do all notifications
      def do_notify
        JacintheManagement.log("Notifying #{@selected_keys.join(' ')}")
        Notifications.notify_all(@selected_keys, @mode)
      end

      # @param [array] key the category key to be shown
      # @return [String] the formatted key
      def format_key(key)
        "#{key.first} <b>[#{key.last}]</b>"
      end

      # show the confirm dialog and execute
      def confirm
        text = " Notifier #{@selected_size} abonnement(s)"
        return unless GuiQt.confirm_dialog(text)
        answer = do_notify
        report(answer.join("\n"))
        JacintheManagement.log(answer.join("\n"))
        update_classification
        redraw_selection_area
        update_selection
        @show_button.enabled = true
      end

      # ask the SQL base
      def update_classification
        Notifications::Base.build_classified_notifications
        @pending_notifications = Notifications::Base.filtered_classified_notifications
      end

      # redraw the selection_area
      def redraw_selection_area
        @pending_notifications.each_pair.with_index do |(_, value), idx|
          @numbers[idx].text = format(FMT, value.size)
          @check_buttons[idx].enabled = (value.size > 0)
        end
      end

      # SLOT when check_button is clicked
      def update_selection
        @selected_keys = []
        @selected_size = 0
        @pending_notifications.each_pair.with_index do |(key, value), idx|
          if @check_buttons[idx].checked?
            @selected_keys << key
            @selected_size += value.size
          end
        end
        redraw_notify_area
      end

      # update the notify command area
      def redraw_notify_area
        @sel.text = "<b>Notifier #{@selected_size} abonnement(s) ?</b>"
        @sel.enabled = (@selected_size > 0)
        @notify_button.enabled = (@selected_size > 0)
        number = Notifications::Base.notifications_number
        @number.text = "<b>Notification à faire pour #{number} abonnement(s)</b>"
      end

      # slot
      def open_model_directory
        Utils.open_file(Core::MODEL_DIR)
      end

      # FIXME: add help
      #  slot help command
      def help
        puts 'add help'
      end
    end
  end
end
