# encoding: utf-8

require_dependency 'application_helper'
module WatcherGroupsPlugin
  module WatcherPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
      base.class_eval do
        belongs_to :user, class_name: "Principal"
        alias_method_chain :validate_user, :groups
      end
    end
    module InstanceMethods
      def validate_user_with_groups
        if self.user.is_a?(Group)
          errors.add :user_id, :invalid unless self.user.users.active.count > 0
        else
          validate_user_without_groups
        end
      end
    end
  end
end
Watcher.send(:include, WatcherGroupsPlugin::WatcherPatch)


