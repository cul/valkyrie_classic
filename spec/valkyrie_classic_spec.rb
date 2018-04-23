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
  end
end
