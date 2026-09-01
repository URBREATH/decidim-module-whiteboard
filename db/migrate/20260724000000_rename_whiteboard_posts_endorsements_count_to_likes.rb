# frozen_string_literal: true

class RenameWhiteboardPostsEndorsementsCountToLikes < ActiveRecord::Migration[7.0]
  def change
    rename_column :decidim_whiteboard_iframes, :endorsements_count, :likes_count
  end
end
