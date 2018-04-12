# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Valkyrie::Classic::Storage::Fedora3 do
  let(:file) { open('.travis.yml', 'rb') }
  before do
    Valkyrie::StorageAdapter.register(storage_adapter, :fedora3)
  end
  after do
    Valkyrie::StorageAdapter.unregister(:fedora3)
  end
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
    it_behaves_like "a Valkyrie::StorageAdapter"
  end
  describe "Valkyrie::StorageAdapter.register" do
    let(:repository) { instance_double(Rubydora::Repository) }
    let(:storage_adapter) { described_class.new(connection: repository) }
    it "can register a storage_adapter by a short name for easier access" do
      expect(Valkyrie::StorageAdapter.find(:fedora3)).to eq storage_adapter
    end
  end
  context "non-public API methods" do
    let(:repository) { instance_double(Rubydora::Repository) }
    let(:storage_adapter) { described_class.new(connection: repository) }
    let(:fedora_obj) { instance_double(Rubydora::DigitalObject) }
    let(:datastream_class) { Struct.new(:dsid, :content) }
    let(:datastreams) { { 'not_a_number' => datastream_class.new(dsid: 'not_a_number') } }
    before { allow(fedora_obj).to receive(:datastreams).and_return datastreams }
    describe "_next_dsid" do
      it "mints the next generic dsid" do
        dsid = storage_adapter._next_dsid(fedora_obj)
        expect(dsid).to eql "ds1"
        datastreams[dsid] = datastream_class.new(dsid: dsid)
        expect(storage_adapter._next_dsid(fedora_obj)).to eql("ds2")
        datastreams["ds0123"] = datastream_class.new(dsid: "ds0123")
        expect(storage_adapter._next_dsid(fedora_obj)).to eql("ds124")
      end
    end
  end
end
