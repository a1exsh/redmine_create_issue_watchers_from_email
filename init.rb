require 'redmine'

Redmine::Plugin.register :redmine_create_issue_watchers_from_email do
  name 'Redmine Create Issue Watchers From Email plugin'
  author 'Alex Shulgin <ash@commandprompt.com>'
#  description 'This is a plugin for Redmine'
  version '0.2.0'
#  url 'http://example.com/path/to/plugin'
#  author_url 'http://example.com/about'

  settings :default => {},
    :partial => 'settings/redmine_create_issue_watchers_from_email'
end

prepare_block = Proc.new do
  Issue.send(:include, RedmineCreateIssueWatchersFromEmail::IssuePatch)
  MailHandler.send(:include, RedmineCreateIssueWatchersFromEmail::MailHandlerPatch)
end

if Rails.env.development?
  ActionDispatch::Reloader.to_prepare { prepare_block.call }
else
  prepare_block.call
end
