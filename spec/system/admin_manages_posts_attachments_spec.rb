# frozen_string_literal: true

require "spec_helper"

describe "Admin manages posts attachments" do
  include_context "with a component"
  let(:manifest_name) { "whiteboard" }
  let!(:post) { create(:post, component: current_component, title: { en: "Post title 1" }) }

  include_context "when managing a component as an admin"

  it_behaves_like "manage posts attachments"
end
