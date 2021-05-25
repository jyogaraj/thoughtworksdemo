#instance = search("aws_opsworks_instance").first
#Chef::Log.info("********** The instance's hostname is '#{instance['hostname']}' **********")
#Chef::Log.info("********** The instance's ID is '#{instance['instance_id']}' **********")

#instance = search("aws_opsworks_instance", "self:true").first
#Chef::Log.info("********** For instance '#{instance['instance_id']}', the instance's public IP address is '##{instance['public_ip']}' **********")

#layer = search("aws_opsworks_layer").first
#Chef::Log.info("'#{layer}'")
#Chef::Log.info("********** The layer's name is '#{layer['name']}' **********")
#Chef::Log.info("********** The layer's shortname is '#{layer['shortname']}' **********")
layerID = ''
dbhostip = ''
search("aws_opsworks_layer").each do |layer|
  Chef::Log.info("********** The layer's name is '#{layer['name']}' **********")
  Chef::Log.info("********** The layer's shortname is '#{layer['shortname']}' **********")
  if layer['name'] == 'mariadb-layer'
    Chef::Log.info("********** The layer's id is '#{layer['layer_id']}' **********")
    layerID = layer['layer_id']
  end
end
Chef::Log.info("********** The layer's id is '#{layerID}' **********")


search("aws_opsworks_instance").each do |instance|
    Chef::Log.info("********** The instance's hostname is '#{instance['hostname']}' **********")
    Chef::Log.info("********** The instance's ID is '#{instance['instance_id']}' **********")
    Chef::Log.info("#{instance['layer_ids']}")
    if instance['layer_ids'].include?(layerID)
        Chef::Log.info("#{instance['status']}")
        if instance['status'] == 'online'
            Chef::Log.info("#{instance['instance_id']}")
            Chef::Log.info("#{instance['private_ip']}")
            dbhostip = instance['private_ip']
        end
    end
end

node[:mysql][:hostip] = dbhostip

instance = search("aws_opsworks_instance", "self:true").first
Chef::Log.info("********** For instance '#{instance['instance_id']}', the instance's public IP address is '##{instance['public_dns']}' **********")
node[:instance][:publicdns] = instance['public_dns']

template 'mediawiki configuration' do
    path '/var/www/mw/LocalSettings.php'
    source 'LocalSettings.erb'
    backup false
    owner 'root'
    group 'root'
    mode 0644
end