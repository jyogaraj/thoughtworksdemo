#
# Cookbook:: thoughtworksdemo
# Recipe:: phpsetup
#
# Copyright:: 2021, The Authors, All Rights Reserved.

package "amazon-linux-extras" do
    retries 3
    retry_delay 5
end
  
execute 'enable php' do
    command "amazon-linux-extras enable php7.4"
end

execute 'clean metadata' do
    command "yum clean metadata"
end

['libzip','php-cli','php-common','php-json','php','libxslt','php-xml','oniguruma','php-mbstring','php-pdo','php-mysqlnd'].each do |package|
    package "#{package}" do
        retries 3
        retry_delay 5
    end
end
