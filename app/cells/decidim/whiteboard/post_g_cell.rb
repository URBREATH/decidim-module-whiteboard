# frozen_string_literal: true

module Decidim
  module Whiteboard
    # This cell renders the Grid (:g) post card
    # for a given instance of a Post
    class PostGCell < Decidim::CardGCell
      delegate :photo, to: :model

      private

      def show_description?
        true
      end

      def metadata_cell
        "decidim/whiteboard/post_metadata_g"
      end

      def resource_image_url
        return if photo.blank?

        photo.url
      end
    end
  end
end
