module RedmineCreateIssueWatchersFromEmail
  module IssuePatch
    unloadable

    def self.included(base)
      base.class_eval do
        alias_method_chain :update, :activate_watchers
      end
    end

    def update_with_activate_watchers(*args)
      update_without_activate_watchers(*args).tap do |x|
        activate_watchers if x && !closed?
      end
    end

    private

    def activate_watchers
      activate_user(author)
      watcher_users.each {|u| activate_user(u)}
    end

    def activate_user(user)
      user.activate! unless user.locked? || user.active?
    end
  end
end
