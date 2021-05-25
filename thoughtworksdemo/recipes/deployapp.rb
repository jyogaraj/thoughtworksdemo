#
# Cookbook:: thoughtworksdemo
# Recipe:: deployapp
#
# Copyright:: 2021, The Authors, All Rights Reserved.

require 'securerandom'
random_string = SecureRandom.hex

git "/tmp/#{random_string}" do
  repository "https://github.com/jyogaraj/mediawiki-app.git"
  revision "main"
  action :sync
end

execute 'untar archive' do
    command "tar -zxvf /tmp/#{random_string}/mediawiki-1.35.2.tar.gz -C /var/www"
end

link '/var/www/mw' do
    to '/var/www/mediawiki-1.35.2'
    link_type :symbolic
end

ruby_block "replace document root" do
    block do
      fe = Chef::Util::FileEdit.new("/etc/httpd/conf/httpd.conf")
      fe.search_file_replace(/"\/var\/www\/html"/,"/var\/www\/\mw")
      fe.write_file
    end
end

service "httpd" do
    action [:restart]
end
