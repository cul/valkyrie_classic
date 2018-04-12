# frozen_string_literal: true
module Valkyrie
  module Classic
    module Storage
      class Fedora3
        attr_reader :connection

        PATTERN = /^info:fedora\/[a-zA-Z][a-zA-Z0-9]+\:[a-zA-Z][a-zA-Z0-9]+\/[a-zA-Z][a-zA-Z0-9]+/

        def initialize(connection:)
          @connection = connection
        end

        def handles?(id:)
          id.to_s.match? PATTERN
        end

        def find_by(id:)
          raise Valkyrie::StorageAdapter::FileNotFound, id unless handles? id: id
          id_segments = id.to_s.split('/')
          # TODO: rewrite using an IO-lke proxy that can rewind and uses http range requests
          response = connection.datastream_dissemination(pid: id_segments[1], dsid: id_segments[2])
          raise Valkyrie::StorageAdapter::FileNotFound, id if response.code.to_i > 399
          io = StringIO.new(response)
          Valkyrie::StorageAdapter::StreamFile.new(id: id.to_s, io: io)
        rescue RestClient::NotFound
          raise Valkyrie::StorageAdapter::FileNotFound, id
        end

        def delete(id:)
          return nil unless handles? id: id
          id_segments = id.to_s.split('/')
          fedora_obj = _fedora_object(id)
          fedora_obj.datastreams[id_segments[2]].delete
        end

        def upload(file:, resource:, original_filename:)
          id_segments = resource.id.to_s.split('/')
          pid = id_segments[1]
          obj_id = "#{id_segments[0]}/#{pid}"
          if resource.is_a? Valkyrie::StorageAdapter::File
            raise "not a Fedora 3 resource" unless handles?(id: resource.id.to_s)
            dsid = id_segments[2]
          else
            raise "not a Fedora 3 resource" unless handles?(id: resource.id.to_s + '/ex')
          end
          raise "resource does not exist" unless (fedora_obj = _fedora_object(obj_id))
          ds = Rubydora::Datastream.new(fedora_obj, dsid || _next_dsid(fedora_obj), dsLabel: original_filename)
          ds.content = file
          ds.save
          find_by(id: "#{obj_id}/#{ds.dsid}")
        end

        # not part of a public API
        def _fedora_object(id)
          id_segments = id.to_s.split('/')
          connection.find(id_segments[1])
        end

        # not part of public API
        def _next_dsid(fedora_obj)
          dsids = fedora_obj.datastreams.keys.select { |dsidv| dsidv =~ /^ds[\d]+/ }
          dsids.map! { |dsidv| dsidv[2..-1] }
          dsids.map!(&:to_i).sort!
          "ds#{(dsids[-1] || 0).to_i + 1}"
        end
      end
    end
  end
end
