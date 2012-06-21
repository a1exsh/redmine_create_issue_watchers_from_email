module RedmineCreateIssueWatchersFromEmail
  module IssuePatch
    unloadable

    def self.included(base)
      base.class_eval do
        alias_method_chain :save, :activate_watchers
      end
    end

    def save_with_activate_watchers
      activate_watchers unless closed?
      save_without_activate_watchers
    end

    private

    def activate_watchers
      activate_user(author)
      watcher_users.each {|u| activate_user(u)}
    end

    def activate_user(user)
      user.activate! unless user.locked?
    end
  end
end
