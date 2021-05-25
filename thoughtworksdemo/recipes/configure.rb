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

template '/var/www/mw/LocalSettings.php' do
    source 'LocalSettings.erb'
    owner 'root'
    variables(
      'db_host': dbhostip,
      'instance_public_dns': instance['public_dns']
    )
    action :create
end