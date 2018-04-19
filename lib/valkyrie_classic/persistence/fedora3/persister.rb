# frozen_string_literal: true
module Valkyrie
  module Classic
    module Persistence
      module Fedora3
        class Persister
          include Valkyrie::Classic::InternalApi

          attr_reader :connection

          PATTERN = /^info:fedora\/[a-zA-Z][a-zA-Z0-9]+\:[a-zA-Z][a-zA-Z0-9]+/

          def initialize(connection:)
            @connection = connection
          end

          def handles?(id:)
            _handles_obj(id: id)
          end

          def save(resource:)
            raise "unhandled resource" unless resource.id.nil? || handles(id: resource.id)
            obj = _fedora_object({ id: resource.id, connection: connection }, true)
            # TODO: apply attribute changes
            obj.save
            resource.created_at = obj.createdDate
            resource.updated_at = obj.lastModifiedDate
            resource
          end

          def save_all(resources:)
            resources.each { |resource| save(resource: resource) }
          end

          def delete(resource:, tombstone: true)
            obj = _fedora_object(id: resource.id, connection: connection)
            return unless obj
            if tombstone
              obj.status = 'D' # mark deleted
              obj.save
            else
              obj.delete
            end
          end
        end
      end
    end
  end
end
