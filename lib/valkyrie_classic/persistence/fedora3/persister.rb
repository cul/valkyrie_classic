# frozen_string_literal: true
module Valkyrie
  module Classic
    module Persistence
      module Fedora3
        module Persister
          attr_reader :connection

          PATTERN = /^info:fedora\/[a-zA-Z][a-zA-Z0-9]+\:[a-zA-Z][a-zA-Z0-9]+/

          def initialize(connection:)
            @connection = connection
          end

          def handles?(id:)
            id.to_s.match? PATTERN
          end

          def save(resource:); end

          def save_all(resources:)
            resources.each { |resource| save(resource: resource) }
          end

          def delete(resource:); end

          # not part of a public API
          def _fedora_object(id)
            id_segments = id.to_s.split('/')
            connection.find(id_segments[1])
          end
        end
      end
    end
  end
end
