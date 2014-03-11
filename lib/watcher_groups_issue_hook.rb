#encoding: utf-8
module WatcherGroupsIssueHooks
  class WatcherGroupsIssueAfterSaveHooks < Redmine::Hook::ViewListener
    # Context:
    # * :issue => Issue being saved
    # * :params => HTML parameters
    #

    def controller_issues_new_after_save(context={})
      if "watcher_group_ids".in? context[:params][:issue]
        context[:issue].watcher_groups_ids = context[:params][:issue]["watcher_group_ids"]
        context[:issue].save
      end
    end
  end
end
