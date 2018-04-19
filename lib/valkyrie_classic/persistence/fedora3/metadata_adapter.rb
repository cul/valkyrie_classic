# frozen_string_literal: true
module Valkyrie
  module Classic
    module Persistence
      module Fedora3
        class MetadataAdapter
          include Valkyrie::Classic::InternalApi

          attr_reader :connection

          def initialize(connection:)
            @connection = connection
          end

          def handles?(id:)
            _handles_obj(id: id)
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
