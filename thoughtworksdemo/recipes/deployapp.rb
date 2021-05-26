#
# Cookbook:: thoughtworksdemo
# Recipe:: deployapp
#
# Copyright:: 2021, The Authors, All Rights Reserved.

require 'securerandom'
random_string = SecureRandom.hex

directory "/tmp/#{random_string}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

remote_file "/tmp/#{random_string}/mediawiki-1.35.2.tar.gz" do
  source 'https://releases.wikimedia.org/mediawiki/1.35/mediawiki-1.35.2.tar.gz'
  mode '0755'
  action :create
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
      fe.search_file_replace(/"\/var\/www\/html"/,"#{node['mediawiki']['path']}")
      fe.write_file
    end
end

layerID = ''
dbhostip = ''
search("aws_opsworks_layer").each do |layer|
  Chef::Log.info("********** The layer's name is '#{layer['name']}' **********")
  if layer['name'] == "#{node[:mysql][:layername]}"
    layerID = layer['layer_id']
  end
end
Chef::Log.info("********** The Database layer's id is '#{layerID}' **********")

db_instances=[]
search("aws_opsworks_instance").each do |instance|
    Chef::Log.info("********** The instance's hostname is '#{instance['hostname']}' **********")
    Chef::Log.info("********** The #{instance['hostname']} layerid is #{instance['layer_ids']}**********")
    if instance['layer_ids'].include?(layerID)
        Chef::Log.info("#{instance['instance_id']} - #{instance['hostname']} - #{instance['status']}")
        if instance['status'] == 'online'
          db_instances.push(instance['private_ip'])
        end
    end
end
print db_instances

db_instances.each do |instip|
  bash 'DB Configure Mediawiki' do
    user 'root'
    cwd  "#{node['mediawiki']['path']}"
    code <<-EOH
    /usr/bin/php #{node['mediawiki']['path']}/maintenance/install.php --conf #{node['mediawiki']['path']}/LocalSettings.php #{node['mediawiki']['title']} admin --pass #{node['mediawiki']['password']} --dbname wikidatabase --dbuser wiki --dbpass #{node['mysql']['wiki_user_password']} --dbserver #{instip} --lang #{node['mediawiki']['lang']} --scriptpath '' --server ''
    EOH
    not_if { ::File.exist?(node['mediawiki']['path'] + '/LocalSettings.php') }
  end
end

execute "move file" do
  command "mv /var/www/mw/LocalSettings.php /var/tmp"
  not_if { ::File.exist?('/var/tmp/LocalSettings.php') }
  only_if { ::File.exist?('/var/www/mw/LocalSettings.php') }
end

instance = search("aws_opsworks_instance", "self:true").first

#template '/var/www/mw/LocalSettings.php' do
#    source 'LocalSettings.erb'
#    owner 'root'
#    variables(
#      'db_host': dbhostip || node[:dbhost],
#      'instance_public_dns': instance['public_dns']
#    )
#    action :create
#end

search("aws_opsworks_elastic_load_balancer").each do |elastic_load_balancer|
  Chef::Log.info("********** The ELB's DNS name is '#{elastic_load_balancer['dns_name']}' **********")
  if elastic_load_balancer['layer_id'] == layerID
    Chef::Log.info("********** The ELB's DNS name is '#{elastic_load_balancer['dns_name']}' **********")
    dbhostip = elastic_load_balancer['dns_name']
  end
end

db_host = dbhostip || node[:dbhost]

bash 'Install mediawiki LB' do
  user 'root'
  cwd  "#{node['mediawiki']['path']}"
  code <<-EOH
  /usr/bin/php #{node['mediawiki']['path']}/maintenance/install.php --conf #{node['mediawiki']['path']}/LocalSettings.php #{node['mediawiki']['title']} admin --pass #{node['mediawiki']['password']} --dbname wikidatabase --dbuser wiki --dbpass #{node['mysql']['wiki_user_password']} --dbserver #{db_host} --lang #{node['mediawiki']['lang']} --scriptpath '' --server ''
  EOH
  not_if { ::File.exist?(node['mediawiki']['path'] + '/LocalSettings.php') }
end

service "httpd" do
    action [:restart]
end
