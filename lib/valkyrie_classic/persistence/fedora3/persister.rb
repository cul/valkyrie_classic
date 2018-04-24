# frozen_string_literal: true
module Valkyrie
  module Classic
    module Persistence
      module Fedora3
        class Persister
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

          def save(resource:)
            raise "unhandled resource: #{resource.id}" unless resource.id.nil? || handles?(id: resource.id)
            _ensure_multiple_values!(resource)
            obj = _fedora_object(adapter.id_to_uri(id: resource.id), connection, true)
            # TODO: apply attribute changes
            obj.save
            # TODO: deal with externally applied/legacy cmodel statements
            _ensure_model("info:fedora/valkyrie:#{resource.class.name}", obj)
            resource.id = obj.uri unless resource.id
            resource.created_at = obj.createdDate
            resource.updated_at = obj.lastModifiedDate
            resource.new_record = false
            resource
          end

          def save_all(resources:)
            resources.each { |resource| save(resource: resource) }
          end

          def delete(resource:, tombstone: false)
            obj = _fedora_object(adapter.id_to_uri(id: resource.id), connection)
            return unless obj
            if tombstone
              obj.state = 'D' # mark deleted
              obj.save
            else
              obj.delete
            end
          end

          # non-public API
          def _ensure_multiple_values!(resource)
            bad_keys = resource.attributes.except(:internal_resource, :created_at, :updated_at, :new_record, :id).select do |_k, v|
              !v.nil? && !v.is_a?(Array)
            end
            raise ::Valkyrie::Persistence::UnsupportedDatatype, "#{resource}: #{bad_keys.keys} have non-array values, which can't be persisted by Valkyrie. Cast to arrays." unless bad_keys.keys.empty?
          end

          def _ensure_model(model, obj)
            return if obj.profile['objModels'].include? model
            obj.models << model
            obj.save
          end

          def _desc_metadata(obj)
            obj.datastreams['descMetadata']
          end
        end
      end
    end
  end
end
