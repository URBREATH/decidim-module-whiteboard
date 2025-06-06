# frozen_string_literal: true

module Decidim
  module Whiteboard
    # Custom helpers used in posts views
    module PostsHelper
      include Decidim::ApplicationHelper
      include Decidim::TranslationsHelper
      include Decidim::ResourceHelper

      # Public: truncates the post body
      #
      # post - a Decidim::Whiteboard instance
      # max_length - a number to limit the length of the body
      #
      # Returns the post's body truncated.
      def post_description(post, max_length = 300)
        body = translated_attribute(post.body)
        CGI.unescapeHTML html_truncate(body, max_length:)
      end
    end
  end
end
