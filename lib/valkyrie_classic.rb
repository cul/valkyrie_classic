# frozen_string_literal: true
module Valkyrie
  module Classic
    require 'valkyrie_classic/version'

    def self.fedora_config
      @fedora_config ||= YAML.load_file('config/fedora.yml')
    end

    def self.solr_config
      @solr_config ||= YAML.load_file('config/solr.yml')
    end
  end
end
