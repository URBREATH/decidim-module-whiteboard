# frozen_string_literal: true

module Decidim
  module Whiteboard
    module AdminLog
      # This class holds the logic to present a `Decidim::Whiteboard::Post`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you should not need to call this class
      # directly, but here is an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    PostPresenter.new(action_log, view_helpers).present
      class PostPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.whiteboard.admin_log.post.#{action}"
          else
            super
          end
        end

        def diff_fields_mapping
          {
            title: :i18n,
            body: :i18n
          }
        end
      end
    end
  end
end
