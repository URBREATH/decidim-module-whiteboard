# frozen_string_literal: true

module Decidim
  module Whiteboard
    # This cell renders the List (:l) post card
    # for a given instance of a Post
    class PostLCell < Decidim::CardLCell
      delegate :photo, to: :model

      private

      def has_description?
        true
      end

      def description_length
        500
      end

      def metadata_cell
        "decidim/whiteboard/post_metadata"
      end

      def resource_image_url
        return if photo.blank?

        photo.url
      end
    end
  end
end
