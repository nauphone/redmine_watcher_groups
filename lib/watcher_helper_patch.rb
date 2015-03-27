module WatcherGroupsPlugin
  module WatchersHelperPatch

    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :watchers_list, :groups
      end
    end
    module InstanceMethods
      def watchers_list_with_groups(object)
        remove_allowed = User.current.allowed_to?("delete_#{object.class.name.underscore}_watchers".to_sym, object.project)
        content = ''.html_safe
        user_in_groups = []
        object.watcher_groups.collect {|group| user_in_groups += group.users.active }

        lis = object.watcher_users.collect do |user|
          s = ''.html_safe
          s << avatar(user, :size => "16").to_s
          s << link_to_user(user, :class => 'user')
          if remove_allowed and not user.in? user_in_groups
            url = {:controller => 'watchers',
                   :action => 'destroy',
                   :object_type => object.class.to_s.underscore,
                   :object_id => object.id,
                   :user_id => user}
            s << ' '
            s << link_to(image_tag('delete.png'), url,
                         :remote => true, :method => 'delete', :class => "delete")
          end
          content << content_tag('li', s, :class => "user-#{user.id}")
        end
        content.present? ? content_tag('ul', content, :class => 'watchers') : content
      end
    end
  end
end
WatchersHelper.send(:include, WatcherGroupsPlugin::WatchersHelperPatch)
