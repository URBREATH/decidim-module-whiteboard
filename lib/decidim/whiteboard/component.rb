# frozen_string_literal: true

Decidim.register_component(:whiteboard) do |component|
  component.engine = Decidim::Whiteboard::Engine
  component.admin_engine = Decidim::Whiteboard::AdminEngine
  component.icon = "media/images/decidim_whiteboard.svg"
  component.icon_key = "blackboard-line"
  component.permissions_class_name = "Decidim::Whiteboard::Permissions"

  #component.query_type = "Decidim::Whiteboard::WhiteboardType"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Cannot remove this component" if Decidim::Whiteboard::Post.where(component: instance).any?
  end

  component.register_stat :posts_count, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, _start_at, _end_at|
    Decidim::Whiteboard::Post.where(component: components).count
  end

  component.actions = %w(create update destroy)

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :comments_max_length, type: :integer, required: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :likes_enabled, type: :boolean, default: true
    settings.attribute :likes_blocked, type: :boolean
  end

  component.register_resource(:blogpost) do |resource|
    resource.model_class_name = "Decidim::Whiteboard::Post"
    resource.card = "decidim/whiteboard/post"
    resource.actions = %w(like comment)
    resource.searchable = true
  end

  component.seeds do |participatory_space|
    require "decidim/whiteboard/seeds"

    Decidim::Whiteboard::Seeds.new(participatory_space:).call
  end
end
