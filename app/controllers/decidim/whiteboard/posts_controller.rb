# frozen_string_literal: true

module Decidim
  module Whiteboard
    # Exposes the blog resource so users can view them
    class PostsController < Decidim::Whiteboard::ApplicationController
      include Flaggable
      include Paginable
      include Decidim::IconHelper

      helper_method :posts, :post, :post_presenter, :paginate_posts, :posts_most_commented, :tabs, :panels

      def index; end

      def show
        raise ActionController::RoutingError, "Not Found" unless post

        @iframe_src = @post.iframe_src
        @iframe_width = @post.iframe_width
        @iframe_height = @post.iframe_height

        add_additional_csp_directives
      end

      def add_additional_csp_directives
        return if @iframe_src.blank?

        allowed_sources_for(@iframe_src).each do |source|
          next if source.blank?

          content_security_policy.append_csp_directive("frame-src", source)
        end
      end
      

      private

      def allowed_sources_for(url)
        sources = []
        sources << url
        origin = origin_from_url(url)
        sources << origin if origin.present?
        sources.compact.uniq
      end

      def origin_from_url(url)
        uri = URI.parse(url)
        return nil unless uri.scheme && uri.host

        origin = "#{uri.scheme}://#{uri.host}"
        origin += ":#{uri.port}" if uri.port && uri.port != uri.default_port
        origin
      rescue URI::InvalidURIError
        nil
      end

      def paginate_posts
        @paginate_posts ||= paginate(posts.created_at_desc)
      end

      def post
        @post ||= posts.find(params[:id])
      end

      def post_presenter
        @post_presenter ||= Decidim::Whiteboard::PostPresenter.new(post)
      end

      def posts
        @posts ||= if current_user&.admin?
                     Post.where(component: current_component)
                   else
                     Post.published.where(component: current_component)
                   end
      end

      # PROVISIONAL if we implement counter cache
      def posts_most_commented
        @posts_most_commented ||= posts.joins(:comments).group(:id)
                                       .select("count(decidim_comments_comments.id) as counter")
                                       .select("decidim_whiteboard_iframes.*").order("counter DESC").created_at_desc.limit(7)
      end
    end
  end
end
