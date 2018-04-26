# frozen_string_literal: true
module Valkyrie
  module Classic
    module Persistence
      module Fedora3
        class QueryService
          include Valkyrie::Classic::InternalApi

          attr_reader :connection
          attr_reader :adapter

          def initialize(connection:, adapter:)
            @connection = connection
            @adapter = adapter
          end

          def handles?(id:)
            _handles_obj(id: id) || _prefixable(id: id)
          end

          def custom_queries
            @custom_queries ||= ::Valkyrie::Persistence::CustomQueryContainer.new(query_service: self)
          end

          def find_all
            raise "unimplemented"
          end

          def find_all_of_model(model:)
            raise "unimplemented"
          end

          def find_by(id:)
            raise ArgumentError, "id<#{id.class}> must be Valkyrie::ID or String" unless _valid_id_class(id)
            raise Valkyrie::Persistence::ObjectNotFoundError, "not a Valkyrie::Classic resource ID" unless handles?(id: id)
            obj = _fedora_object(adapter.id_to_uri(id: id), connection, true)
            raise Valkyrie::Persistence::ObjectNotFoundError, id.to_s if obj.new?
            resource_class = adapter.resource_class_from_fedora(obj)
            resource = resource_class.new(id: id, new_record: false)
            _apply_attributes(obj, resource)
            resource.created_at = obj.createdDate
            resource.updated_at = obj.lastModifiedDate
            resource.new_record = false
            resource
          end

          def find_by_alternate_identifier(alternate_identifier:)
            raise ArgumentError, "id must be Valkyrie::ID or String" unless _valid_id_class(alternate_identifier)
            raise "unimplemented"
          end

          def find_many_by_ids(ids:)
            raise ArgumentError, "id must be Valkyrie::ID or String" if ids.detect { |id| !_valid_id_class(id) }
            result = []
            ids.each do |id|
              begin
                result << find_by(id: id)
              rescue Valkyrie::Persistence::ObjectNotFoundError
                result.length
              end
            end
            result
          end

          def find_members(resource:, model: nil)
            raise "unimplemented"
          end

          def find_references_by(resource:, property:)
            raise "unimplemented"
          end

          def find_inverse_references_by(resource:, property:)
            raise ArgumentError, "cannot query inverse references for unpersisted resources" unless resource.persisted?
            raise "unimplemented"
          end

          def find_parents(resource:)
            raise "unimplemented"
          end

          def _apply_attributes(obj, resource)
            graph = RDF::Graph.new
            graph.from_ntriples(obj.datastreams['descMetadata'].content || "")
            _collect_attributes(graph, resource).each { |att, vals| resource.send("#{att}=".to_sym, vals) }
          end

          def _collect_attributes(graph, resource)
            atts = Hash.new { |hash, key| hash[key] = [] }
            graph.statements.each do |statement|
              next unless _attribute_statement?(statement, resource)
              attribute = statement.predicate.to_s.sub("info:valkyrie/attributes#", '').to_sym
              if statement.object.node? # RDF::List
                atts[attribute].concat _all_list_values(RDF::List.new(subject: statement.object, graph: graph))
              else
                atts[attribute] << ValueMarshaller.unmarshaller_for(statement.object).unmarshall(statement.object)
              end
            end
            atts
          end

          def _attribute_statement?(statement, resource)
            statement.predicate.to_s.start_with?("info:valkyrie/attributes#") && statement.subject == RDF::URI(adapter.id_to_uri(id: resource.id))
          end

          def _all_list_values(list)
            list.map { |value| ValueMarshaller.unmarshaller_for(value).unmarshall(value) }
          end
        end
      end
    end
  end
end
