# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages post" do
  let(:manifest_name) { "whiteboard" }
  let!(:post1) { create(:post, component: current_component, author:, title: { en: "Post title 1" }) }
  let!(:post2) { create(:post, component: current_component, title: { en: "Post title 2" }) }
  let(:author) { create(:user, organization:) }

  include_context "when managing a component as a process admin"

  it_behaves_like "manage posts", audit_check: false
end
