# frozen_string_literal: true
require "spec_helper"

describe Valkyrie::Classic do
  it "has a version number" do
    expect(Valkyrie::Classic::VERSION).not_to be_nil
  end
  it "has fedora configurations" do
    expect(described_class.fedora_config).not_to be_empty
    expect(described_class.fedora_config).to have_key :url
  end
  it "has solr configurations" do
    expect(described_class.solr_config).not_to be_empty
    expect(described_class.solr_config).to have_key 'url'
  end
  describe Valkyrie::Classic::InternalApi do
    let(:test_rig) { Class.new }
    before { test_rig.send :include, Valkyrie::Classic::InternalApi }
    let(:test_obj) { test_rig.new }
    it "#_handles_obj" do
      expect(test_obj._handles_obj(id: "info:fedora/changeme:24")).to be true
      expect(test_obj._handles_obj(id: "info:fedora/changeme:24/DC")).to be false
    end
    it "#_handles_ds" do
      expect(test_obj._handles_ds(id: "info:fedora/changeme:24/DC")).to be true
      expect(test_obj._handles_ds(id: "info:fedora/changeme:24")).to be false
    end
    it "#_prefixable" do
      expect(test_obj._prefixable(id: "24")).to be true
      expect(test_obj._prefixable(id: SecureRandom.uuid)).to be true
      expect(test_obj._prefixable(id: "info:fedora")).to be false
    end
    context "needs a test resource" do
      before do
        class MyStruct < Valkyrie::Resource
          attribute :title
          attribute :examples, Valkyrie::Types::Array
        end
      end
      after do
        Object.send(:remove_const, :MyStruct)
      end
      it "#_is_valkyrie_array_type" do
        expect(test_obj._is_valkyrie_array_type(MyStruct.new, :examples)).to be true
        expect(test_obj._is_valkyrie_array_type(MyStruct.new, :title)).to be false
        expect(test_obj._is_valkyrie_array_type(MyStruct.new, :examples)).to be true
        expect(test_obj._is_valkyrie_array_type(MyStruct.new, :member_ids)).to be true
      end
    end
  end
end
