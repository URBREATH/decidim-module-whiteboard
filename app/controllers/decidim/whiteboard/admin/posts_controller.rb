# frozen_string_literal: true

module Decidim
  module Whiteboard
    module Admin
      # This controller allows the create or update a blog.
      class PostsController < Admin::ApplicationController
        helper UserGroupHelper
        helper PostsHelper

        helper_method :iframe, :remove_margins?, :viewport_width?
        before_action :allow_spacedeck_iframe, only: [:new, :edit]

        

        def new
          enforce_permission_to :create, :blogpost
          @form = form(PostForm).instance
        end

        def create
          enforce_permission_to :create, :blogpost
          @form = form(PostForm).from_params(params, current_component:)

          CreatePost.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("posts.create.success", scope: "decidim.whiteboard.admin")
              redirect_to posts_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("posts.create.invalid", scope: "decidim.whiteboard.admin")
              render action: "new"
            end
          end
        end


        def allow_spacedeck_iframe
          content_security_policy.append_csp_directive(
            "frame-src",
            "https://spacedeck-dev.urbreath.tech https://keycloak-dev.urbreath.tech http://localhost:9666",
          )
        end


        def iframe
          @iframe ||= sanitize(
            element
          ).html_safe
        end
  
        def element
          case content_height
          when "16:9"
            "<iframe id=\"iFrame\" class=\"aspect-ratio-16-9\" src=\"#{attributes.src}\" width=\"#{content_width}\"
            frameborder=\"#{attributes.frameborder}\"></iframe>"
          when "4:3"
            "<iframe id=\"iFrame\" class=\"aspect-ratio-4-3\" src=\"#{attributes.src}\" width=\"#{content_width}\"
            frameborder=\"#{attributes.frameborder}\"></iframe>"
          when "auto"
            "<iframe id=\"iFrame\" src=\"#{attributes.src}\" width=\"#{content_width}\"
            frameborder=\"#{attributes.frameborder}\"></iframe>"
          when "manual_pixel"
            "<iframe id=\"iFrame\" src=\"#{attributes.src}\" width=\"#{content_width}\"
            height=\"#{attributes.height_value}px\"frameborder=\"#{attributes.frameborder}\"></iframe>"
          end
        end
  
        def attributes
          @attributes ||= current_component.settings
        end
  
        def content_height
          attributes.content_height
        end
  
        def content_width
          case attributes.content_width
          when "full_width"
            "100%"
          when "manual_pixel"
            "#{attributes.width_value}px"
          when "manual_percentage"
            "#{attributes.width_value}%"
          end
        end
  
        def sanitize(html)
          sanitizer = Rails::Html::SafeListSanitizer.new
          partially_sanitized_html = sanitizer.sanitize(html, tags: %w(iframe), attributes: %w(src id width height frameborder class))
          document = Nokogiri::HTML::DocumentFragment.parse(partially_sanitized_html)
          document.css("iframe").each do |iframe|
            iframe["srcdoc"] = Loofah.fragment(iframe["srcdoc"]).scrub!(:prune).to_s if iframe["srcdoc"]
          end
  
          document.to_s
        end
  
        def remove_margins?
          attributes.no_margins
        end
  
        def viewport_width?
          attributes.viewport_width
        end
  
        def add_additional_csp_directives
          iframe_urls = Nokogiri::HTML::DocumentFragment.parse(iframe).children.select { |x| x.name == "iframe" }.filter_map { |x| x.attribute("src")&.value }
          return if iframe_urls.blank?
  
          iframe_urls.each do |url|
            content_security_policy.append_csp_directive("frame-src", url)
          end
        end

        def edit
          enforce_permission_to :update, :blogpost, blogpost: post
          @form = form(PostForm).from_model(post)
        end

        def update
          enforce_permission_to :update, :blogpost, blogpost: post
          @form = form(PostForm).from_params(params, current_component:)

          UpdatePost.call(@form, post) do
            on(:ok) do
              flash[:notice] = I18n.t("posts.update.success", scope: "decidim.whiteboard.admin")
              redirect_to posts_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("posts.update.invalid", scope: "decidim.whiteboard.admin")
              render action: "edit"
            end
          end
        end


        def destroy
          enforce_permission_to :destroy, :blogpost, blogpost: post

          Decidim::Commands::DestroyResource.call(post, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("posts.destroy.success", scope: "decidim.whiteboard.admin")
              redirect_to posts_path
            end
          end
        end

        private

        def post
          @post ||= Whiteboard::Post.find_by(component: current_component, id: params[:id])
        end
      end
    end
  end
end
