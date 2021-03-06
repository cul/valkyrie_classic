# frozen_string_literal: true
require 'rubydora'
require 'rsolr'
module Valkyrie
  module Classic
    require 'valkyrie_classic/version'
    require 'valkyrie_classic/storage'
    require 'valkyrie_classic/storage/fedora3'

    def self.fedora_config
      @fedora_config ||= YAML.load_file('config/fedora.yml')[ENV['RAILS_ENV']]
    end

    def self.solr_config
      @solr_config ||= YAML.load_file('config/solr.yml')[ENV['RAILS_ENV']]
    end

    def self.fedora_repo(config = fedora_config)
      @fedora_repo ||= Rubydora.connect(config)
    end

    def self.solr_connection(config = solr_config)
      @rsolr ||= RSolr.connect(config)
    end
  end
end
