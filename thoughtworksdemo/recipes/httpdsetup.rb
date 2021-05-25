#
# Cookbook:: thoughtworksdemo
# Recipe:: httpdsetup
#
# Copyright:: 2021, The Authors, All Rights Reserved.

package "httpd" do
    retries 3
    retry_delay 5
end

service 'httpd' do
    action [:enable, :start]
end