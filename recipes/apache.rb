#
# Cookbook Name:: gitlab
# Recipe:: apache
#
# Copyright 2012, Gerald L. Hevener Jr., M.S.
# Copyright 2012, Eric G. Wolfe
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Render gitlab init script
template "/etc/init.d/gitlab" do
  owner "root"
  group "root"
  mode 0755
  source "gitlab.init.sidekiq.only.erb"
  variables(
      :gitlab_app_home => node['gitlab']['app_home'],
      :gitlab_user => node['gitlab']['user']
  )
end

web_app "gitlab" do
  docroot "#{node[:gitlab][:app_home]}/public"
  template "gitlab.conf.erb"
  server_name node['gitlab']['apache_server_names'].join(' ')
  server_aliases node['gitlab']['apache_server_names'].join(' ')
  rails_env "production"
end
