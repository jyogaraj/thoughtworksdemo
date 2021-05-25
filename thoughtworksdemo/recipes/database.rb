#
# Cookbook:: thoughtworksdemo
# Recipe:: database
#
# Copyright:: 2021, The Authors, All Rights Reserved.
mysql_name  = node[:mysql][:name] || "mysql"

#Install package
package "#{mysql_name}-server" do
  retries 3
  retry_delay 5
end

service "mariadb" do
    action [:enable, :start]
end

cookbook_file  '/tmp/sqlcommands.sql' do
    source 'sqlcommands.sql'
end

cookbook_file  '/tmp/hardening.sql' do
    source 'hardening.sql'
end

ruby_block "replace password" do
    block do
      fe = Chef::Util::FileEdit.new("/tmp/sqlcommands.sql")
      fe.search_file_replace(/"THISpasswordSHOULDbeCHANGED"/,"#{node[:mysql][:wiki_user_password]}")
      fe.write_file
    end
end

execute 'assign root password' do
    command "#{node[:mysql][:mysqladmin_bin]} -u root password \"#{node[:mysql][:server_root_password]}\""
    action :run
    only_if "#{node[:mysql][:mysql_bin]} -u root -e 'show databases;'"
end

execute 'hardening db' do
    command "#{node[:mysql][:mysql_bin]} -u root -p#{node[:mysql][:server_root_password]} < /tmp/hardening.sql"
    action :run
    only_if "#{node[:mysql][:mysql_bin]} -u root -p#{node[:mysql][:server_root_password]} -e 'show databases like \"test\"'|grep test"
end

execute 'create db for wiki' do
    command "#{node[:mysql][:mysql_bin]} -u root -p#{node[:mysql][:server_root_password]} < /tmp/sqlcommands.sql"
    action :run
    not_if "#{node[:mysql][:mysql_bin]} -u root -p#{node[:mysql][:server_root_password]} -e 'show databases like \"wikidatabase\"'|grep wikidatabase"
end