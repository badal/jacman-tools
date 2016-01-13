#!/usr/bin/env ruby
# encoding: utf-8

# File: collective_manager_central_widget.rb
# Created: 9 june 2015 from 29 april 2015 file
#
# (c) Michel Demazure <michel@demazure.com>

# script methods for Jacinthe Management
module JacintheManagement
  module GuiQt
    # Central widget for collective subscriptions management
    class CollectiveManagerCentralWidget < CentralWidget
      # version of the collective_manager
      VERSION = '0.3.2'
      # "About" specific message
      SPECIFIC = [
        "   jacman_coll : #{JacintheManagement::Coll::VERSION}",
        "   collective subscription manager : #{VERSION}"
      ]
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
        'Création des abonnements collectifs'
      end

      # @return [Array<String>] about message
      def about
        [subtitle] + ABOUT
      end

      # build the layout
      def build_layout
        init_values
        build_name_line
        build_client_line
        build_journal_choices
        build_report_area
        build_command_area
        load_all_collectives
      end

      # fix initial values
      def init_values
        @collectives = []
        @journals = Coll.journals
        @subscriber = nil
      end

      # load all collectives from the database
      def load_all_collectives
        @collectives = Coll::Collective.extract_all
        @collective_names = @collectives.map(&:name_space_year)
        report('-' * 30)
        report 'Abonnements disponibles'
        @collective_names.each { |name| report name }
        report('-' * 30)
      end

      # build the corresponding part
      def build_name_line
        box = Qt::HBoxLayout.new
        add_layout(box)
        box.add_widget(Qt::Label.new('Nom :'))
        @name_field = Qt::LineEdit.new
        box.add_widget(@name_field)
        connect(@name_field, SIGNAL_EDITING_FINISHED) { process_name_field }
        box.add_widget(Qt::Label.new('Année :'))
        @year_field = Qt::LineEdit.new
        box.add_widget(@year_field)
        connect(@year_field, SIGNAL_EDITING_FINISHED) { @year = @year_field.text.strip }
      end

      # build the corresponding part
      def build_client_line
        add_widget(Qt::Label.new('<b>Le financeur</b>'))
        box = Qt::HBoxLayout.new
        add_layout(box)
        box.add_widget(Qt::Label.new('Client :'))
        @client_field = Qt::LineEdit.new
        box.add_widget(@client_field)
        connect(@client_field, SIGNAL_EDITING_FINISHED) do
          fetch_client(@client_field.text.strip)
        end
        box.add_widget(Qt::Label.new('Facture :'))
        @billing_field = Qt::LineEdit.new
        box.add_widget(@billing_field)
        connect(@billing_field, SIGNAL_EDITING_FINISHED) { @billing = @billing_field.text.strip }
      end

      # build the corresponding part
      def build_journal_choices
        @selections = {}
        @check = []
        add_widget(Qt::Label.new('<b> Les revues</b>'))
        @journals.each_with_index do |(_, journal), idx|
          next unless journal
          box = Qt::HBoxLayout.new
          add_layout(box)
          @check[idx] = Qt::CheckBox.new
          connect(@check[idx], SIGNAL_CLICKED) { @selections[idx] = @check[idx].checked? }
          box.add_widget(@check[idx])
          box.add_widget(Qt::Label.new(journal))
          box.add_stretch
        end
      end

      # build the corresponding partyuhtg-
      def build_report_area
        @report = Qt::TextEdit.new('')
        add_widget(@report)
        @report.read_only = true
      end

      # build the corresponding part
      def build_command_area
        add_widget(Qt::Label.new('<b>Actions</b>'))
        box = Qt::HBoxLayout.new
        add_layout(box)
        @create_button = Qt::PushButton.new('Créer  un abo. coll.')
        connect(@create_button, SIGNAL_CLICKED) { create_collective }
        box.add_widget(@create_button)
        @load_button = Qt::PushButton.new('Charger un abo. coll.')
        connect(@load_button, SIGNAL_CLICKED) { load_collective }
        box.add_widget(@load_button)
        # FIXME: disabled
        @load_button.enabled = false
        update_button = Qt::PushButton.new('Enregistrer l\'abo. coll.')
        connect(update_button, SIGNAL_CLICKED) { update_collective }
        box.add_widget(update_button)
      end

      # show an error message
      # @param [String] message message to show
      def error(message)
        @report.append('<font color=red><b>' 'ERREUR</b> : </color> ' + message)
      end

      # show an report message
      # @param [String] message message to show
      def report(message)
        @report.append(message)
      end

      # WARNING: overrides the common one, useless in this case
      def update_values
      end

      # HTML help file
      HELP_FILE = File.expand_path('manager.html/#coll', Core::HELP_DIR)

      # Slot: open the help file
      def help
        url = Qt::Url.new("file:///#{HELP_FILE}")
        p url
        Qt::DesktopServices.openUrl(url)
      end

      ## Controller methods

      # slot
      def process_name_field
        @name = @name_field.text.strip
        load_collective_if_possible if @extracting
      end

      ## fill_in methods

      # try and load a collective
      def load_collective_if_possible
        selected = @collectives.find { |coll| coll.name == @name }
        return unless selected
        @collective = selected
        fill_in
        report "abonnement #{selected.name_space_year} chargé"
      end

      # fill the parameters of the selected collective
      def fill_in
        @name_field.text = @name = @collective.name
        @client_field.text = @provider = @collective.provider
        @year_field.text = @year = @collective.year.to_s
        @billing_field.text = @billing = @collective.billing
        check_journals(@collective.journal_ids)
      end

      # @param [Array<Integer>] list ids of selected journals
      def check_journals(list)
        list.each do |jrl|
          @check[jrl].checked = true
          @selections[jrl] = true
        end
      end

      # create action has been selected
      def create_collective
        @load_button.enabled = false
        @extracting = false
      end

      # loading action has been selected
      def load_collective
        @create_button.enabled = false
        @extracting = true
        load_collective_if_possible
      end

      # check if given client exists in DB and return its id
      #
      # @param [String] client id given by user
      # @return [String | nil] valid client_id or nil
      def fetch_client(client)
        return if client == @provider
        if Coll.fetch_client("'#{client}'")
          @provider = client
          report("Client #{@provider} identifié")
          client
        else
          error('Ce client n\'existe pas')
          nil
        end
      end

      # check if variable has got a correct value
      #
      # @param [String] variable who should be non blank
      # @param [String] term name for the user
      # @return [Bool] whether variable exists and not blank
      def check(variable, term)
        return true if variable && !variable.empty?
        error("Pas de #{term}")
        false
      end

      # build collective if possible and report
      #
      # @return [Subscriber | nil] collective subscriber built
      def build_collective
        return nil unless check(@name, 'nom de l\'abonnement') &&
                          check(@provider, 'client') &&
                          check(@billing, 'facture') &&
                          check(@year, 'année')
        @journal_ids = @selections.select { |_, bool| bool }.map { |key, _| key }.sort
        if @journal_ids.size == 0
          error 'pas de revues'
          return nil
        end
        Coll::Collective.new(@name, @provider, @billing, @journal_ids, @year.to_i)
      end

      # do update the loaded collective
      def update_collective
        built = build_collective
        return unless built
        @collective = built
        if @collective_names.include?(built.name_space_year)
          error "Un abonnement de nom #{@name} existe"
          return
        end
        return unless GuiQt.confirm_dialog(built_parameters)
        puts @collective.insert_in_database
        load_all_collectives
      end

      # @return [String] parameters of built collective
      def built_parameters
        @collective.report.join("\n")
      end
    end
  end
end
