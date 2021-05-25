#
# Cookbook:: thoughtworksdemo
# Recipe:: httpdstop
#
# Copyright:: 2021, The Authors, All Rights Reserved.


service 'httpd' do
    action [:stop]
end