# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Classic::Persistence::Fedora3::Persister do
  let(:flags) { [:no_deep_nesting, :no_mixed_nesting] }
  context "running integration suite", if: ENV['COVERAGE'] do
    let(:storage_adapter) { described_class.new(connection: Valkyrie::Classic.fedora_repo) }
    before :all do
      Valkyrie::Classic.fedora_repo.find_or_initialize("test:test").save
    end
    after :all do
      Valkyrie::Classic.fedora_repo.purge_object(pid: "test:test")
    end
    before do
      class CustomResource < Valkyrie::Resource
        def initialize(args = {})
          super(args.merge(id: id_for(args[:id])))
        end

        def id_for(base_val)
          "info:fedora/test:#{base_val}"
        end
      end
    end
    it_behaves_like "a Valkyrie::Persister"
  end
end
