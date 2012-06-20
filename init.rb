require 'redmine'
require 'dispatcher'

Dispatcher.to_prepare do
  require_dependency 'mail_handler'
  MailHandler.send(:include, RedmineCreateIssueWatchersFromEmail::MailHandlerPatch)
end

Redmine::Plugin.register :redmine_create_issue_watchers_from_email do
  name 'Redmine Create Issue Watchers From Email plugin'
  author 'Alex Shulgin <ash@commandprompt.com>'
  description 'This is a plugin for Redmine'
  version '0.0.1'
#  url 'http://example.com/path/to/plugin'
#  author_url 'http://example.com/about'

  settings :default => {},
    :partial => 'settings/redmine_create_issue_watchers_from_email'
end
