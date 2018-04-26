# frozen_string_literal: true
module Valkyrie
  module Classic
    # shared methods not part of a public API
    module InternalApi
      OBJECT_URI_PATTERN = /^info\:fedora\/[a-zA-Z][a-zA-Z0-9]+\:[a-zA-Z0-9][a-zA-Z0-9]*$/
      DATASTREAM_URI_PATTERN = /^info\:fedora\/[a-zA-Z][a-zA-Z0-9]+\:[a-zA-Z0-9][a-zA-Z0-9]*\/[a-zA-Z][a-zA-Z0-9]+$/
      PREFIXABLE_PATTERN = /^[a-zA-Z0-9][a-zA-Z0-9\-]*$/

      def _handles_obj(id:)
        id.to_s.match? OBJECT_URI_PATTERN
      end

      def _handles_ds(id:)
        id.to_s.match? DATASTREAM_URI_PATTERN
      end

      def _prefixable(id:)
        id.to_s.match? PREFIXABLE_PATTERN
      end

      def _fedora_object(id, connection, create = false)
        id_segments = id.to_s.split('/')
        create ? connection.find_or_initialize(id_segments[1]) : connection.find(id_segments[1])
      end

      def _valid_id_class(id)
        id.is_a?(Valkyrie::ID) || id.is_a?(String)
      end

      def _is_valkyrie_array_type(resource, attribute_name)
        attribute_key = attribute_name.to_sym
        # member_ids is a magic attribute in Valkyrie 1
        return true if attribute_key.eql?(:member_ids)
        attribute = resource.class.schema[attribute_key]
        return false unless attribute.is_a? Dry::Types::Default
        return attribute.type.type.is_a?(Dry::Types::Array) if attribute.type.is_a? Dry::Types::Constructor
        false
      end
    end
  end
end
