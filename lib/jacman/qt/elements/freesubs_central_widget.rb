#!/usr/bin/env ruby
# encoding: utf-8

# File: freesubs_central_widget.rb
# Created: 2 july 2015
#
# (c) Michel Demazure <michel@demazure.com>

# script methods for Jacinthe Management
module JacintheManagement
  module GuiQt
    # Central widget for collective subscriptions management
    class FreesubsCentralWidget < CentralWidget
      # version of the free_subs manager
      slots :update_window
      VERSION = '0.1.0'

      # "About" message
      ABOUT = ['Versions :',
               "   jacman-qt : #{JacintheManagement::VERSION}",
               "   jacman-utils : #{JacintheManagement::Utils::VERSION}",
               # "   jacman_coll : #{JacintheManagement::Coll::VERSION}",
               "   free subscriptions manager : #{VERSION}",
               'S.M.F. 2015',
               "\u00A9 Michel Demazure, LICENCE M.I.T."]

      SIGNAL_EDITING_FINISHED = SIGNAL('editingFinished()')
      SIGNAL_CLICKED = SIGNAL(:clicked)

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
        'Management des abonnements gratuits et d\'échange'
      end

      # @return [Array<String>] about message
      def about
        [subtitle] + ABOUT
      end

      # build the layout
      def build_layout
        @extender = Freesubs::Extender.new(Freesubs::YEAR)
        @check_buttons = []
        @ins = []
        fetch_updated_sizes

        @number = Qt::Label.new
        @layout.add_widget(@number)
        @number.text = caption_text(@extensible_size)

        add_extender_area
        add_command_area
        add_report_area
        check_all_buttons
      end

      def add_extender_area
        @extender.all_acronyms.zip(@extender.names).each_with_index do |(acro, name), idx|
          Qt::HBoxLayout.new do |line|
            @layout.add_layout(line)
            number = Qt::Label.new(format(FMT, @extensible_sizes[idx]))
            @ins[idx] = number
            line.add_widget(number)
            Qt::CheckBox.new do |button|
              @check_buttons[idx] = button
              connect(button, SIGNAL_CLICKED) { update_window }
              line.add_widget(button)
            end
            line.add_widget(Qt::Label.new("<b>#{acro}</b>"))
            line.add_widget(Qt::Label.new(name))
            line.addStretch
          end
        end
      end

      def add_command_area
        Qt::HBoxLayout.new do |box|
          @layout.add_layout(box)
          @sel = Qt::Label.new(extension_text(@extensible_size))
          box.add_widget(@sel)
          button = Qt::PushButton.new("Les étendre  à l'année #{Freesubs::YEAR + 1}")
          box.add_widget(button)
          connect(button, SIGNAL_CLICKED) { confirm }
        end
      end

      def add_report_area
        Qt::HBoxLayout.new do |box|
          @layout.add_layout(box)
          box.add_widget(Qt::Label.new("<b>Mode #{Freesubs::EFFECTIVE ? 'réel' : 'simulé'}</b>"))
          @report = Qt::Label.new
          box.add_widget(@report)
          box.addStretch
        end
      end

      # WARNING: overrides the common one, useless in this case
      def update_values
      end

      # Slot: open the help file
      def help
        url = Qt::Url.new("file:///#{Freesubs::HELP_FILE}")
        Qt::DesktopServices.openUrl(url)
      end

      # Slot: open the config file
      def config
        url = Qt::Url.new("file:///#{Freesubs::CONFIG_FILE}")
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
        "<b>  Année de référence #{Freesubs::YEAR} : il reste #{number} abonnements à étendre à #{Freesubs::YEAR + 1}</b>"
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
        text = "  Etendre #{size} abonnements. Confirmez"
        do_extend(acronyms) if GuiQt.confirm_dialog(text)
      end
    end
  end
end
