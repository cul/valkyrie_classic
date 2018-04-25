# frozen_string_literal: true
module Valkyrie
  module Classic
    module Persistence
      module Fedora3
        FEDORA = RDF::Vocabulary.new("info:fedora/")
        VALKYRIE_TYPE = RDF::Vocabulary.new("info:valkyrie/datatypes#")
        VALKYRIE_BOOLEAN_TYPE = VALKYRIE_TYPE.boolean
        VALKYRIE_DATETIME_TYPE = VALKYRIE_TYPE.datetime
        VALKYRIE_INTEGER_TYPE = VALKYRIE_TYPE.integer
        VALKYRIE_TIME_TYPE = VALKYRIE_TYPE.time

        class ValueMarshaller
          # Register a marshaller.
          # @param marshaller [Valkyrie::Classic::Persistence::Fedora3::ValueMarshaller]
          def self.register(marshaller)
            marshallers << marshaller
          end

          # @return [Array<Valkyrie::Classic::Persistence::Fedora3::ValueMarshaller>] Registered value casters.
          def self.marshallers
            @marshallers ||= []
          end

          def self.marshaller_for(val)
            marshallers.find { |m| m.marshalls? val } || new
          end

          def self.unmarshaller_for(val)
            marshallers.find { |m| m.unmarshalls? val } || new
          end

          # @param Valkyrie::Resource attribute value
          def marshalls?(_val)
            false
          end

          # @param RDF::Literal
          def unmarshalls?(_val)
            false
          end

          # convert to a RDF::Literal
          # @param Valkyrie::Resource attribute value
          # @return RDF::Literal
          def marshall(val)
            val
          end

          # convert to original attribute value
          # @param RDF::Literal
          # @return Valkyrie::Resource attribute value
          def unmarshall(literal)
            literal.object
          end
        end

        class IdMarshaller < ValueMarshaller
          include Valkyrie::Classic::InternalApi

          ValueMarshaller.register(new)

          def marshalls?(val)
            val.is_a?(Valkyrie::ID)
          end

          def unmarshalls?(val)
            val.is_a?(RDF::URI) && val.start_with?(FEDORA)
          end

          def marshall(val)
            id = val.to_s
            id = "info:fedora/valkyrie:#{id}" if _prefixable(id: id)
            RDF::URI(id)
          end

          def unmarshall(val)
            id = val.to_s
            id = id.split(':')[-1] if id.to_s.start_with?("info:fedora/valkyrie:")
            Valkyrie::ID.new(id)
          end
        end

        class LiteralPassthrough < ValueMarshaller
          ValueMarshaller.register(new)

          def marshalls?(val)
            val.is_a?(RDF::Literal) && !RDF::URI(val.datatype).start_with?(VALKYRIE_TYPE)
          end

          def unmarshalls?(val)
            val.is_a?(RDF::Literal) && !RDF::URI(val.datatype).start_with?(VALKYRIE_TYPE)
          end

          def marshall(val)
            val
          end

          def unmarshall(val)
            val
          end
        end

        class UriPassthrough < ValueMarshaller
          ValueMarshaller.register(new)

          def marshalls?(val)
            val.is_a?(RDF::URI) && !val.start_with?(FEDORA)
          end

          def unmarshalls?(val)
            val.is_a?(RDF::URI) && !val.start_with?(FEDORA)
          end

          def marshall(val)
            val
          end

          def unmarshall(val)
            val
          end
        end

        class BooleanMarshaller < ValueMarshaller
          ValueMarshaller.register(new)

          def marshalls?(val)
            val.is_a?(TrueClass) || val.is_a?(FalseClass)
          end

          def unmarshalls?(val)
            val.is_a?(RDF::Literal) && val.datatype == VALKYRIE_BOOLEAN_TYPE
          end

          def marshall(val)
            RDF::Literal.new(val.to_s, datatype: VALKYRIE_BOOLEAN_TYPE)
          end

          def unmarshall(val)
            val.object.to_s.casecmp? 'true'
          end
        end

        class DateTimeMarshaller < ValueMarshaller
          ValueMarshaller.register(new)

          def marshalls?(val)
            val.is_a?(DateTime)
          end

          def unmarshalls?(val)
            val.is_a?(RDF::Literal) && val.datatype == VALKYRIE_DATETIME_TYPE
          end

          def marshall(val)
            RDF::Literal.new(val.to_i, datatype: VALKYRIE_DATETIME_TYPE)
          end

          def unmarshall(val)
            Time.utc(*Time.at(val.object.to_i).utc.to_a)
          end
        end

        class IntegerMarshaller < ValueMarshaller
          ValueMarshaller.register(new)

          def marshalls?(val)
            val.is_a?(Integer)
          end

          def unmarshalls?(val)
            val.is_a?(RDF::Literal) && val.datatype == VALKYRIE_INTEGER_TYPE
          end

          def marshall(val)
            RDF::Literal.new(val.to_s, datatype: VALKYRIE_INTEGER_TYPE)
          end

          def unmarshall(val)
            val.object.to_s.to_i
          end
        end

        class TimeMarshaller < ValueMarshaller
          ValueMarshaller.register(new)

          def marshalls?(val)
            val.is_a?(Time)
          end

          def unmarshalls?(val)
            val.is_a?(RDF::Literal) && val.datatype == VALKYRIE_TIME_TYPE
          end

          def marshall(val)
            RDF::Literal.new(val.to_i, datatype: VALKYRIE_TIME_TYPE)
          end

          def unmarshall(val)
            Time.utc(*Time.at(val.object.to_i).utc.to_a)
          end
        end
      end
    end
  end
end
