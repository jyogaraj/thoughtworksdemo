DELETE FROM mysql.user WHERE User='';
CREATE USER 'wiki'@'%' IDENTIFIED BY 'THISpasswordSHOULDbeCHANGED';
CREATE DATABASE wikidatabase;  
GRANT ALL PRIVILEGES ON wikidatabase.* TO 'wiki'@'%';
FLUSH PRIVILEGES;
SHOW DATABASES;
SHOW GRANTS FOR 'wiki'@'%';
