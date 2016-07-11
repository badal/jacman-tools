#!/usr/bin/env ruby
# encoding: utf-8

# File: billing_central_widget.rb
# Created:  july 2015
#
# (c) Michel Demazure <michel@demazure.com>

# script methods for Jacinthe Management
module JacintheManagement
  module GuiQt
    # Central widget for SQL manager
    class BillingCentralWidget < CentralWidget
      # version of the Billing_manager
      VERSION = '0.1.0'
      # "About" specific message
      SPECIFIC = [
          "   billing_manager : #{VERSION}"
      ]
      # "About message"
      ABOUT = GuiQt.tools_versions(SPECIFIC)

      INIT = 'call query_tiers_init();'
      SEARCH = "call query_tiers_add_tiers_from_billing('BILLING');"
      SHOW = 'select * from TMP_query_tiers;'

      def search_query(billing)
        INIT + SEARCH.sub(/BILLING/, billing) + SHOW
      end

      # @return [[Integer] * 4] geometry of mother window
      def geometry
        if Utils.on_mac?
          [100, 100, 600, 350]
        else
          [100, 100, 400, 300]
        end
      end

      # @return [String] name of manager specialty
      def subtitle
        'Recherche des tiers facturés'
      end

      # @return [Array<String>] about message
      def about
        [subtitle] + ABOUT
      end

      # build the layout
      def build_layout
        build_search_line
        build_content_area
      end

      def build_search_line
        box = Qt::HBoxLayout.new
        add_layout(box)
        box.add_widget(Qt::Label.new('Facture :'))
        @billing = Qt::LineEdit.new
        box.add_widget(@billing)
        connect(@billing, SIGNAL(:returnPressed)) { search(@billing.text) }
        @tiers = Qt::Label.new('--- Tiers ----')
        box.add_widget(@tiers)
        box.add_stretch

      end

      def build_content_area
        box = Qt::HBoxLayout.new
        add_layout(box)
        @content = Qt::TextEdit.new
        box.add_widget(@content)
      end

      def search(billing)
        answer = Sql.answer_to_query(JACINTHE_MODE, search_query(billing))
        answer.empty? ? report_not_found : report_found(answer)
      end

      def report_not_found
        @tiers.text = '--- Pas de tiers trouvé'
        @content.text = ''
      end

      def report_found(answer)
        answer.shift
        tiers_id = answer.first.split("\t").first
        @tiers.text = "Tiers : #{tiers_id}"
        content = answer.map { |line| (line.split("\t"))[1] }.join
        @content.text = content
      end

      # WARNING: overrides the common one, useless in this case
      def update_values
      end

      # FIXME: add help
      #  slot help command
      def help
        puts 'add help'
      end
    end
  end
end

__END__

      # build the type line
      def build_type_line
        box = Qt::HBoxLayout.new
        add_layout(box)
        @type = Qt::ComboBox.new
        @type.add_items(SQLFiles::TYPES)
        box.add_widget(Qt::Label.new('Type :'))
        box.add_widget(@type)
        connect(@type, SIGNAL('activated(int)')) { info_edited }
      end

      # build the selection line
      def build_selection_line
        list = [FIRST_LINE] + SQLFiles::Source.all
        @selection = Qt::ComboBox.new
        @selection.add_items(list)
        add_widget(@selection)
        connect(@selection, SIGNAL('activated(const QString&)')) { |name| file_selected(name) }
      end

      # build the zone for information
      def build_info_zone
        SQLFiles::KEYS.each_pair do |key, value|
          @info_values[key] = Qt::LineEdit.new(NEANT)
          box = Qt::HBoxLayout.new
          add_layout(box)
          label = Qt::Label.new(value.to_s)
          box.add_widget(label)
          box.add_widget(@info_values[key])
          connect(@info_values[key], SIGNAL('textChanged(const QString&)')) { info_edited }
        end
      end

      # build the zone to show the content of the file
      def build_content_zone
        @content = Qt::TextEdit.new
        add_widget(@content)
        @content.read_only = true
      end

      # build the dialog line
      def build_modif_line
        box = Qt::HBoxLayout.new
        @modif = Qt::Label.new('')
        box.add_widget(@modif)
        @save_button = Qt::PushButton.new('Enregistrer les modifications')
        box.add_widget(@save_button)
        connect(@save_button, SIGNAL(:clicked)) { save_infos }
        add_layout(box)
      end

      # build the execution line
      def build_execution_line
        box = Qt::HBoxLayout.new
        @clone_exec_button = Qt::PushButton.new('Exécuter dans le clone')
        box.add_widget(@clone_exec_button)
        @clone_exec_button.enabled = false
        connect(@clone_exec_button, SIGNAL(:clicked)) { clone_execute }
        @exec_button = Qt::PushButton.new('Exécuter')
        box.add_widget(@exec_button)
        @exec_button.enabled = false
        connect(@exec_button, SIGNAL(:clicked)) { execute }
        add_layout(box)
      end

      # set all starting values
      def empty_values
        @type.current_index = 0
        SQLFiles::KEYS.each_key do |key|
          @info_values[key].text = NEANT
        end
        @content.text = ''
      end

      # slot: a filename has been selected
      # @param [String] name name of file
      def file_selected(name)
        if @no_change || @saved_index == 0 || GuiQt.confirm_dialog(confirm_text)
          change_selection(name)
        else
          @selection.set_current_index(@saved_index)
        end
      end

      # update the GUI with the new selected file
      # @param [String] name name of file
      def change_selection(name)
        @saved_index = @selection.current_index
        if name == FIRST_LINE
          empty_values
          return
        end
        @file = SQLFiles::Source.new(name)
        update_content
        update_infos
      end

      # slot: info has changed
      def info_edited
        build_new_info
        @no_change = (@saved_index == 0) || (@new_info == @file.info)
        @modif.text = @no_change ? '' : '<b>Informations modifiées</b>'
        @save_button.enabled = !@no_change
      end

      # slot: save infos in JSON file after confirmation dialog
      def save_infos
        return unless GuiQt.confirm_dialog('Enregistrer les modifications')
        do_save_infos
      end

      # save the infos in JSON file
      def do_save_infos
        @file.save_json_info(@new_info)
        JacintheManagement.log("saved new infos for #{@file.name}")
        info_edited
      end

      # @return [String] text to ask for confirmation
      def confirm_text
        [
          "Les informations sur le fichier  <b>#{@file.name}.sql</b> ",
          'ont été modifiées, mais n\'ont pas été enregistrées.',
          'Voulez-vous vraiment ignorer ces modifications ?'
        ].join("\n")
      end

      # build the new infos from what was entered
      def build_new_info
        @new_info = {}
        @new_info[:type] = @type.current_text.force_encoding('utf-8')
        SQLFiles::KEYS.each_key do |key|
          new_text = @info_values[key].text.force_encoding('utf-8').strip
          next if new_text == NEANT
          @new_info[key] = new_text
        end
      end

      # update the content area
      def update_content
        @content.text = @file.content
      end

      # update the shown infos
      def update_infos
        @type.set_current_index(@file.type_index)
        @info_values.each_pair do |key, line|
          line.text = @file.info[key] || NEANT
        end
        @exec_button.enabled = @file.query?
        @clone_exec_button.enabled = @file.executable?
      end

      # slot: execute the sql query and show the result
      def execute
        answer = Sql.answer_to_query(JACINTHE_MODE, @file.script).join
        Qt::MessageBox.information(parent, 'Réponse', answer)
      end

      # slot: execute the sql query in the cloned base and show the result
      def clone_execute
        answer = Sql.answer_to_query(CLONE_MODE, @file.script).join
        Qt::MessageBox.information(parent, 'Réponse', answer)
      end

      # WARNING: overrides the common one, useless in this case
      def update_values
      end

      # FIXME: add help
      #  slot help command
      def help
        puts 'add help'
      end
    end
  end
end
