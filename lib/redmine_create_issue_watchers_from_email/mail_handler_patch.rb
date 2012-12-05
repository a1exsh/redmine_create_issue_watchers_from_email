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

      handler_options = MailHandler.send(:class_variable_get, :@@handler_options)
      notify_user = !handler_options[:no_account_notice]

      sender_addr = email.from.first
      mail_is_from_member = project.users.exists?(User.find_by_mail(sender_addr))

      addrs = (email.to_addrs.to_a + email.cc_addrs.to_a)
      addrs.each do |addr|
        next if addr == emission_email

        watcher = User.find_by_mail(addr)
        unless watcher
          logger.info "MailHandler: creating new watcher user: #{addr}" if logger

          watcher = MailHandler.new_user_from_attributes(addr)
          registered = \
            if mail_is_from_member
              watcher.activate
              watcher.save
            else
              watcher.process_registration(notify_user)
            end
          unless registered
            logger.error "MailHandler: failed to create User: #{watcher.errors.full_messages}" if logger
            next
          end
        end
        unless project.users.exists?(watcher)
          member = Member.new(:user_id => watcher.id, :role_ids => [watcher_role.id])
          project.members << member
        end
      end

      add_watchers_without_create(obj)
    end

    private

    def watcher_role
      @watcher_role ||= Role.find_by_name(settings['watcher_role'])
    end

    def settings
      @settings ||= Setting['plugin_redmine_create_issue_watchers_from_email']
    end
  end
end
