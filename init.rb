require 'watcher_groups/views_issues_hook'
require 'issue_hook'
require 'issue_patch'
require 'issues_controller_patch'
require 'watcher_groups_helper'
require 'watcher_patch'
require 'watcher_helper_patch'

Redmine::Plugin.register :redmine_watcher_groups do
  name 'Redmine Watcher Groups plugin'
  author 'Kamen Ferdinandov, Massimo Rossello, Alexei Margasov'
  description 'This is a plugin for Redmine to add watcher groups functionality'
  version '2.0.0'
  url 'http://github.com/nauphone/redmine_watcher_groups'
  author_url 'http://github.com/nauphone'
end

include WatcherGroupsHelper