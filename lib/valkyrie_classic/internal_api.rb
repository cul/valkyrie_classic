# frozen_string_literal: true
module Valkyrie
  module Classic
    # shared methods not part of a public API
    module InternalApi
      OBJECT_URI_PATTERN = /^info\:fedora\/[a-zA-Z][a-zA-Z0-9]+\:[a-zA-Z0-9][a-zA-Z0-9]*$/
      DATASTREAM_URI_PATTERN = /^info\:fedora\/[a-zA-Z][a-zA-Z0-9]+\:[a-zA-Z0-9][a-zA-Z0-9]*\/[a-zA-Z][a-zA-Z0-9]+$/

      def _handles_obj(id:)
        id.to_s.match? OBJECT_URI_PATTERN
      end

      def _handles_ds(id:)
        id.to_s.match? DATASTREAM_URI_PATTERN
      end

      def _fedora_object(id, connection, create = false)
        id_segments = id.to_s.split('/')
        create ? connection.find_or_initialize(id_segments[1]) : connection.find(id_segments[1])
      end

      def _valid_id_class(id)
        id.is_a?(Valkyrie::ID) || id.is_a?(String)
      end
    end
  end
end
