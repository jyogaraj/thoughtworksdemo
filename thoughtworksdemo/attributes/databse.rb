default[:mysql][:server_root_password] = "admin123"
default[:mysql][:name]                 = "mariadb"
default[:mysql][:bin_dir]              = "/usr/bin"
default[:mysql][:mysqladmin_bin]       = "#{node[:mysql][:bin_dir]}/mysqladmin"
default[:mysql][:mysql_bin]            = "#{node[:mysql][:bin_dir]}/mysql"
default[:mysql][:wiki_user_password]   = "wiki123"
default[:mysql][:hostip]               = ""
default[:mysql][:layername]            = "database"