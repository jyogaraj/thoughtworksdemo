layerID = ''
dbhostip = ''
search("aws_opsworks_layer").each do |layer|
  Chef::Log.info("********** The layer's name is '#{layer['name']}' **********")
  if layer['name'] == 'mariadb-layer'
    layerID = layer['layer_id']
  end
end
Chef::Log.info("********** The layer's id is '#{layerID}' **********")


search("aws_opsworks_instance").each do |instance|
    Chef::Log.info("********** The instance's hostname is '#{instance['hostname']}' **********")
    Chef::Log.info("#{instance['layer_ids']}")
    if instance['layer_ids'].include?(layerID)
        Chef::Log.info("#{instance['instance_id']} - #{instance['status']}")
        if instance['status'] == 'online'
            dbhostip = instance['private_ip']
        end
    end
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

db_host = dbhostip || node[:dbhost]

bash 'Install mediawiki' do
  user 'root'
  cwd  "#{node['mediawiki']['path']}"
  code <<-EOH
  /usr/bin/php #{node['mediawiki']['path']}/maintenance/install.php --conf #{node['mediawiki']['path']}/LocalSettings.php #{node['mediawiki']['title']} admin --pass #{node['mediawiki']['password']} --dbname wikidatabase --dbuser wiki --dbpass #{node['mysql']['wiki_user_password']} --dbserver #{dbhostip} --lang #{node['mediawiki']['lang']} --scriptpath '' --server http://#{instance['public_dns']}
  EOH
  not_if { ::File.exist?(node['mediawiki']['path'] + '/LocalSettings.php') }
end