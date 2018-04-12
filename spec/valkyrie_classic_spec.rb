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
end
