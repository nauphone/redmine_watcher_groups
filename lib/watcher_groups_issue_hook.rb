#encoding: utf-8
module WatcherGroupsIssueHooks
  class WatcherGroupsIssueAfterSaveHooks < Redmine::Hook::ViewListener
    # Context:
    # * :issue => Issue being saved
    # * :params => HTML parameters
    #

    def controller_issues_new_after_save(context={})
      if "watcher_group_ids".in? context[:params][:issue]
        group_ids = context[:params][:issue]["watcher_group_ids"]
        group_ids.each do |group_id|
          issue = Issue.find(context[:issue].id)
          group_users = Group.find(group_id.to_i).users
          group_users.each do |user|
            if !user.in? issue.watcher_users
              note = "Watcher #{user.name} was added"
              journal = Journal.new(:journalized => issue, :user => user, :notes => note, :notify => false, :is_system_note=> true)
              journal.save
              if Setting.notified_events.include?('issue_updated') ||
                        (Setting.notified_events.include?('issue_note_added') && journal.notes.present?)
                Mailer.watcher_add(journal, user.mail).deliver
              end
            end
          end
        end
        context[:issue].watcher_groups_ids = context[:params][:issue]["watcher_group_ids"]
        context[:issue].save
      end
    end
  end
end
