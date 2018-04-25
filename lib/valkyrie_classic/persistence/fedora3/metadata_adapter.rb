# frozen_string_literal: true
module Valkyrie
  module Classic
    module Persistence
      module Fedora3
        class MetadataAdapter
          include Valkyrie::Classic::InternalApi

          attr_reader :connection, :id_mapper

          def initialize(connection:)
            @connection = connection
            @id_mapper = Valkyrie::Classic::Persistence::Fedora3::IdMarshaller.new
          end

          def handles?(id:)
            _handles_obj(id: id) || _prefixable(id: id)
          end

          def persister
            @persister ||= Valkyrie::Classic::Persistence::Fedora3::Persister.new(connection: connection, adapter: self)
          end

          def query_service
            @query_service ||= Valkyrie::Classic::Persistence::Fedora3::QueryService.new(connection: connection, adapter: self)
          end

          def id_to_uri(id:)
            id_mapper.marshall(id).to_s
          end

          def resource_class_from_fedora(obj)
            rels_xml = Nokogiri::XML(obj.datastreams['RELS-EXT'].content)
            ns = { 'fedora-model' => 'info:fedora/fedora-system:def/model#' }
            model_types = rels_xml.xpath('//fedora-model:hasModel', ns).map { |node| node['rdf:resource'].split(':')[-1] }
            model = model_types.find { |type| Object.const_defined?(type) }
            model ||= 'Resource'
            Object.const_get(model)
          end
        end
      end
    end
  end
end
