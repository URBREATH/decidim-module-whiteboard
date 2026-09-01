# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/faker/localized"
require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :post_component, parent: :component do
    transient do
      skip_injection { false }
    end

    name { generate_component_name(participatory_space.organization.available_locales, :whiteboard, skip_injection:) }
    manifest_name { :whiteboard }
    participatory_space { create(:participatory_process, :with_steps, skip_injection:, organization:) }

    trait :with_likes_enabled do
      step_settings do
        {
          participatory_space.active_step.id => { likes_enabled: true }
        }
      end
    end

    trait :with_likes_disabled do
      step_settings do
        {
          participatory_space.active_step.id => { likes_enabled: false }
        }
      end
    end
  end

  factory :post, class: "Decidim::Whiteboard::Post" do
    transient do
      skip_injection { false }
    end

    title { generate_localized_title(:blog_title, skip_injection:) }
    body { generate_localized_description(:blog_body, skip_injection:) }
    component { build(:post_component, skip_injection:) }
    author { build(:user, :confirmed, skip_injection:, organization: component.organization) }

    trait :with_likes do
      after :create do |post, evaluator|
        5.times.collect do
          create(:like,
                 resource: post,
                 skip_injection: evaluator.skip_injection,
                 author: build(:user, skip_injection: evaluator.skip_injection, organization: post.participatory_space.organization))
        end
      end
    end
  end
end
