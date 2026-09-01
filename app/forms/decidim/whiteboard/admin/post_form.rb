# frozen_string_literal: true

module Decidim
  module Whiteboard
    module Admin
      class PostForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :body, String

        # Aggiungi gli attributi per i nuovi campi
        attribute :iframe_src, String
        attribute :iframe_width, String
        attribute :iframe_height, Integer

        attribute :decidim_author_id, Integer
        attribute :published_at, Decidim::Attributes::TimeWithZone

        validates :title, translatable_presence: true
        validates :body, translatable_presence: true
        validate :can_set_author

      # Validazioni aggiuntive per i nuovi campi
validates :iframe_src, presence: true, if: :iframe_conditions?
validates :iframe_height, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

validate :iframe_width_format

def iframe_width_format
  return if iframe_width.blank?
  return if iframe_width == "100%" || iframe_width.to_s =~ /\A\d+\z/
end


        def map_model(model)
          self.decidim_author_id = nil if model.author.is_a? Decidim::Organization
          # Aggiungi il mapping per i nuovi campi
          self.iframe_src = model.iframe_src
          self.iframe_width = model.iframe_width
          self.iframe_height = model.iframe_height
        end

        def user_or_group
          @user_or_group ||= Decidim::UserBaseEntity.find_by(
            organization: current_organization,
            id: decidim_author_id
          )
        end

        def author
          user_or_group || current_organization
        end

        private

        def can_set_author
          return if author == current_user.organization
          return if author == current_user
          return if author == post&.author

          errors.add(:decidim_author_id, :invalid)
        end

        def post
          @post ||= Post.find_by(id: id)
        end
        # Nuovo metodo per la condizione del campo iframe
        def iframe_conditions?
          iframe_width.present? && iframe_height.present?
        end
      end
    end
  end
end
