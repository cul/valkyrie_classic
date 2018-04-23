# frozen_string_literal: true
module Valkyrie
  module Classic
    class ObjectResource < Valkyrie::Resource
      include Valkyrie::Classic::InternalApi

      attribute :id, Valkyrie::Types::ID.optional

      def initialize(*args)
        super
        @fedora_resource ||= _fedora_object(id, connection, true)
        @new_record = false unless @fedora_resource.new?
      end

      def connection
        @connection ||= Valkyrie::Classic.fedora_repo
      end
    end
  end
end
