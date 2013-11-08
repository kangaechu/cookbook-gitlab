#
# Cookbook Name:: gitlab
# Recipe:: nginx
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
  source "gitlab.init.erb"
  variables(
      :gitlab_app_home => node['gitlab']['app_home'],
      :gitlab_user => node['gitlab']['user']
  )
end

# Use certificate cookbook for keys
certificate_manage node['gitlab']['certificate_databag_id'] do
  cert_path '/etc/nginx/ssl'
  owner node['gitlab']['user']
  group node['gitlab']['user']
  nginx_cert true
  only_if { node['gitlab']['https'] and not node['gitlab']['certificate_databag_id'].nil? }
end

# Create nginx directories before dropping off templates
include_recipe "nginx::commons_dir"

# Either listen_port has been configured elsewhere or we calculate it depending on the https flag
listen_port = node['gitlab']['listen_port'] || node['gitlab']['https'] ? 443 : 80

# Render and activate nginx default vhost config
template "/etc/nginx/sites-available/gitlab" do
  owner "root"
  group "root"
  mode 0644
  source "nginx.gitlab.erb"
  notifies :restart, "service[nginx]"
  variables(
      :server_name => node['gitlab']['nginx_server_names'].join(' '),
      :hostname => node['hostname'],
      :gitlab_app_home => node['gitlab']['app_home'],
      :https_boolean => node['gitlab']['https'],
      :ssl_certificate => node['gitlab']['ssl_certificate'],
      :ssl_certificate_key => node['gitlab']['ssl_certificate_key'],
      :listen => "#{node['gitlab']['listen_ip']}:#{listen_port}"
  )
end

include_recipe "nginx"

nginx_site 'gitlab' do
  enable true
end

nginx_site "default" do
  enable false
end
