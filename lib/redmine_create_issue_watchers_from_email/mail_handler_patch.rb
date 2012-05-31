module RedmineCreateIssueWatchersFromEmail
  module MailHandlerPatch
    unloadable

    def self.included(base)
      base.class_eval do
        alias_method_chain :add_watchers, :create
      end
    end

    def add_watchers_with_create(obj)
      # check our emission email to avoid self-notify hell cycles
      project = obj.project
      emission_email = (project.respond_to?(:email) ? project.email : Setting.mail_from).strip.downcase

      (email.to_addrs.to_a + email.cc_addrs.to_a).each do |addr|
        unless User.find_by_mail(addr.spec) || addr.spec == emission_email
          watcher = MailHandler.new_user_from_attributes(addr.spec, addr.name)
          unless watcher.process_registration
            logger.error "MailHandler: failed to create User: #{watcher.errors.full_messages}" if logger
          else
            member = Member.new(:user_id => watcher.id, :role_ids => [watcher_role.id])
            project.members << member
          end
        end
      end

      add_watchers_without_create(obj)
    end

    def watcher_role
      @watcher_role ||= Role.find_by_name("Issue Watcher") # XXX: hard-coded value
    end
  end
end
