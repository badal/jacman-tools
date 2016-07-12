#!/usr/bin/env ruby
# encoding: utf-8

# File: freesubs_central_widget.rb
# Created: 2 july 2015
#
# (c) Michel Demazure <michel@demazure.com>

require_relative('config_button.rb')

# script methods for Jacinthe Management
module JacintheManagement
  module GuiQt
    # Central widget for collective subscriptions management
    class FreesubsCentralWidget < CentralWidget
      include ConfigButton
      # version of the free_subs manager
      slots :update_window
      VERSION = '0.1.0'
      # "About" specific message
      SPECIFIC = [
        "   jacman-extender : #{JacintheManagement::Extender::VERSION}",
        "   free subscriptions manager : #{VERSION}"
      ]
      # "About message"
      ABOUT = GuiQt.tools_versions(SPECIFIC)

      SIGNAL_EDITING_FINISHED = SIGNAL('editingFinished()')
      SIGNAL_CLICKED = SIGNAL(:clicked)
      HELP_FILE = File.join(File.dirname(__FILE__), '../help_files/freesubs_help.pdf')

      def initialize(year = Time.now.year - 1, state = 6)
        @year = year.to_i
        @state = state
        @extender = Extender::Builder.from_state(@year, @state)
        super()
      end

      # @return [[Integer] * 4] geometry of mother window
      def geometry
        if Utils.on_mac?
          [100, 100, 600, 400]
        else
          [100, 100, 400, 350]
        end
      end

      # @return [String] name of manager specialty
      def subtitle
        Extender::Builder.subtitle(@state)
      end

      # @return [Array<String>] about message
      def about
        [subtitle] + ABOUT
      end

      # build the layout
      def build_layout
        add_widget(Qt::Label.new("<b>#{subtitle}</b>"))
        add_config_area
        return unless @extender
        @check_buttons = []
        @ins = []
        fetch_updated_sizes

        @number = Qt::Label.new
        add_widget(@number)
        @number.text = caption_text(@extensible_size)

        add_extender_area
        add_command_area
        add_report_area

        @layout.add_stretch
        check_all_buttons
      end

      # add area
      def add_extender_area
        @extender.all_acronyms.zip(@extender.names).each_with_index do |(acro, name), idx|
          line = Qt::HBoxLayout.new
          add_layout(line)
          add_variable_elements(line, idx)
          line.add_widget(Qt::Label.new("<b>#{acro}</b>"))
          line.add_widget(Qt::Label.new(name))
          line.addStretch
        end
      end

      def add_variable_elements(line, idx)
        @ins[idx] = Qt::Label.new(format(FMT, @extensible_sizes[idx]))
        @check_buttons[idx] = Qt::CheckBox.new
        connect(@check_buttons[idx], SIGNAL_CLICKED) { update_window }
        line.add_widget(@ins[idx])
        line.add_widget(@check_buttons[idx])
      end

      # add area
      def add_command_area
        Qt::HBoxLayout.new do |box|
          add_layout(box)
          @sel = Qt::Label.new(extension_text(@extensible_size))
          box.add_widget(@sel)
          @extend_button = Qt::PushButton.new("Les étendre  à l'année #{@year + 1}")
          box.add_widget(@extend_button)
          connect(@extend_button, SIGNAL_CLICKED) { confirm }
          @extend_button.enabled = (@extensible_size > 0)
        end
      end

      # add area
      def add_report_area
        Qt::HBoxLayout.new do |box|
          add_layout(box)
          box.add_widget(Qt::Label.new("<b>Mode #{@state.odd? ? 'réel' : 'simulé'}</b>"))
          @report = Qt::Label.new
          box.add_widget(@report)
          box.addStretch
        end
      end

      # add area
      def add_config_area
        box = Qt::HBoxLayout.new
        add_layout(box)
        @mode_button = Qt::CheckBox.new('Mode réel')
        @free_button = Qt::CheckBox.new('Gratuits')
        @exchange_button = Qt::CheckBox.new('Echanges')

        init_button_checked_states

        [@mode_button, @free_button, @exchange_button].each do |button|
          box.add_widget(button)
          connect(button, SIGNAL_CLICKED) { state_changed }
        end
      end

      def init_button_checked_states
        @mode_button.set_checked(@state.odd?)
        @free_button.set_checked(@state & 2 == 2)
        @exchange_button.set_checked(@state >= 4)
      end

      def state_changed
        @state = 0
        @state += 1 if @mode_button.is_checked
        @state += 2 if @free_button.is_checked
        @state += 4 if @exchange_button.is_checked
        new_central_widget = FreesubsCentralWidget.new(@year, @state)
        parent.central_widget = new_central_widget
      end

      # WARNING: overrides the common one, useless in this case
      def update_values
      end

      # Slot: open the help file
      def help
        url = Qt::Url.new("file:///#{HELP_FILE}")
        Qt::DesktopServices.openUrl(url)
      end

      # format for *caption_text*
      FMT = '%3d '

      # returns acronyms and size, *and* update window
      # @return [Array<String>, Integer] list of selected acronyms and total size
      def update
        acronyms = selected_acronyms
        size = @extender.total_extensible_size(acronyms)
        @sel.text = extension_text(size)
        [acronyms, size]
      end

      # fetch from the expander the new sizes
      def fetch_updated_sizes
        @extender.update_extension_list
        @extensible_size = @extender.total_extensible_size
        @extensible_sizes = @extender.extensible_sizes
      end

      # @param [Integer] extensible_size total number of extensible Abos
      # @return [String] caption to be shown
      def caption_text(extensible_size)
        number = format(FMT, extensible_size)
        "<b>  Année de référence #{@year} : il reste #{number} abonnements à étendre à #{@year + 1}</b>"
      end

      # @return [Array<String>] list of acronyms of selected kinds
      def selected_acronyms
        data = @extender.all_acronyms.zip(@check_buttons, @extensible_sizes)
        data.select { |_, button, size| button.checked && size > 0 }.map(&:first)
      end

      # update the number of selected Abos
      def show_selected_sizes
        total_size = 0
        @check_buttons.zip(@extensible_sizes).each_with_index do |(button, size), idx|
          selected_size = button.checked ? size : 0
          total_size += selected_size
          @ins[idx].text = format(FMT, selected_size)
        end
        @sel.text = extension_text(total_size)
        @extend_button.enabled = (total_size > 0)
      end

      # @param [Integer] size total number of selected Abos
      # @return [String] caption to be shown
      def extension_text(size)
        "<b>  Il y a #{size} abonnements sélectionnés</b>"
      end

      # put all buttons in the checked state,
      def check_all_buttons
        @check_buttons.zip(@extensible_sizes).each do |button, size|
          button.checked = true
          button.enabled = (size > 0)
        end
      end

      # extend the selected Abos and report
      # @param [Array<String>] acros list of acronyms of selected kinds
      def do_extend(acros)
        number = @extender.extend_list(acros)
        @report.text = " : <b>#{number} abonnements ont été étendus</b>"
        fetch_updated_sizes
        @number.text = caption_text(@extensible_size)
        check_all_buttons
        update_window
      end

      # slot: update window after partial extension
      def update_window
        show_selected_sizes
      end

      # slot: open the confirm dialog and extend
      def confirm
        acronyms, size = update
        return if size == 0
        text = "  Etendre #{size} abonnements. Confirmez"
        do_extend(acronyms) if GuiQt.confirm_dialog(text)
      end
    end
  end
end
