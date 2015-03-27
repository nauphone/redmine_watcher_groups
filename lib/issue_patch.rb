
module WatcherGroupsIssuePatch

  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
    base.class_eval do
      include WatcherGroupsHelper
      alias_method_chain :notified_watchers , :groups
      alias_method_chain :watched_by? , :groups
      alias_method_chain :watcher_users, :users

      scope :watched_by, lambda { |user|
        user = User.find(user) unless user.is_a?(User)
        g = user.groups
        joins(:watchers).where("#{Watcher.table_name}.user_id IN (#{user.id} #{g.empty? ? "" : ","} #{g.map(&:id).join(',')})")
      }
    end
  end

  module InstanceMethods
    def watcher_groups
      if self.id
        watchers = Watcher.where(:watchable_type => self.class, :watchable_id => self.id).to_a
        return Group.where(:id => watchers.map(&:user_id)).to_a
      else
        []
      end
    end

    def watcher_group_ids
      self.watcher_groups.collect {|group| group.id}
    end

    def addable_watcher_groups
      groups = self.project.principals.select{|p| p if p.type=='Group'}
      groups = groups.sort - self.watcher_groups
      if respond_to?(:visible?)
        groups.reject! {|group| !visible?(group)}
      end
      groups
    end

    def watched_by_group?(group)
      !!(group && self.watcher_groups.detect {|gr| gr.id == group.id } unless self.watcher_groups.nil?)
    end


    def notified_watchers_with_groups
      notified = []

      w = Watcher.where(:watchable_type => self.class, :watchable_id => self.id).to_a
      groups = Group.where(:id => w.map(&:user_id)).to_a

      groups.each do |p|
          group_users = p.users.active.to_a
          group_users.reject! {|user| user.mail.blank? || user.mail_notification == 'none'}
          if respond_to?(:visible?)
            group_users.reject! {|user| !visible?(user)}
          end
          notified += group_users
      end
      notified += self.watcher_users
      notified.reject! {|user| user.mail.blank? || user.mail_notification == 'none'}
      if respond_to?(:visible?)
        notified.reject! {|user| !visible?(user)}
      end
      notified.uniq
    end

    def watched_by_with_groups?(user)
      watcher_groups.each do |group|
        return true if user.is_or_belongs_to?(group)
      end
      watched_by_without_groups?(user)
    end

    def watcher_users_with_users
      users = watcher_users_without_users.to_a.reject{|principal| principal if principal.is_a?(Group)}
      watcher_groups.each do |g|
        users += g.users.active
      end
      users.uniq.sort_by(&:name)
    end
  end
end

Issue.send(:include, WatcherGroupsIssuePatch)
