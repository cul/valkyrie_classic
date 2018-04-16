# frozen_string_literal: true
module Valkyrie
  module Classic
    module Persistence
      module Fedora3
        class MetadataAdapter
          attr_reader :connection

          PATTERN = /^info:fedora\/[a-zA-Z][a-zA-Z0-9]+\:[a-zA-Z][a-zA-Z0-9]+/

          def initialize(connection:)
            @connection = connection
          end

          def handles?(id:)
            id.to_s.match? PATTERN
          end

          def persister
            @persister ||= Valkyrie::Classic::Persistence::Fedora3::Persister.new(connection: connection)
          end

          def query_service
            @query_service ||= Valkyrie::Classic::Persistence::Fedora3::QueryService.new(connection: connection)
          end
        end
      end
    end
  end
end
