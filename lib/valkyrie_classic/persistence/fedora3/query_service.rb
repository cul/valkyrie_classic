# frozen_string_literal: true
module Valkyrie
  module Classic
    module Persistence
      module Fedora3
        class QueryService
          include Valkyrie::Classic::InternalApi

          attr_reader :connection

          def initialize(connection:)
            @connection = connection
          end

          def handles?(id:)
            _handles_obj(id: id)
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
            raise ArgumentError, "id must be Valkyrie::ID or String" unless _valid_id_class(id)
            raise Valkyrie::Persistence::ObjectNotFoundError, "not a Valkyrie::Classic resource ID" unless handles?(id: id)
            resource = Valkyrie::Classic::ObjectResource.new(id: id)
            raise Valkyrie::Persistence::ObjectNotFoundError, id.to_s unless resource.persisted?
            resource
          end

          def find_by_alternate_identifier(alternate_identifier:)
            raise ArgumentError, "id must be Valkyrie::ID or String" unless _valid_id_class(alternate_identifier)
            raise "unimplemented"
          end

          def find_many_by_ids(ids:)
            raise ArgumentError, "id must be Valkyrie::ID or String" if ids.detect { |id| !_valid_id_class(id) }
            raise "unimplemented"
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
        end
      end
    end
  end
end
