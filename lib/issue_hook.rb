#encoding: utf-8
module WatcherGroupsIssueHooks
  class WatcherGroupsIssueAfterSaveHooks < Redmine::Hook::ViewListener
    # Context:
    # * :issue => Issue being saved
    # * :params => HTML parameters
    #
    def view_layouts_base_body_bottom(context={})
      return context[:controller].send(:render_to_string, {
        :partial => 'issues/issue_group_watcher_list'
        })
    end

  end
end
