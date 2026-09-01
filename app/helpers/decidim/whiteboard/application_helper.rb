# frozen_string_literal: true

module Decidim
  module Whiteboard
    # Custom helpers, scoped to the whiteboard engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include SanitizeHelper
      include Decidim::Whiteboard::PostsHelper
      include ::Decidim::LikeableHelper
      include ::Decidim::FollowableHelper
      include Decidim::Comments::CommentsHelper

      def component_name
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t("decidim.components.whiteboard.name")
      end
    end
  end
end
