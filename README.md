# oracle_scripts_auoto
创建日志文件
touch /tmp/oracle_service.log
chown -R oracle:oinstall /tmp/oracle_service.log
编辑/etc/sudoer文件添加如下

oracle  ALL=(ALL)       NOPASSWD: /u01/app/oracle/product/11.2.0/db_1/bin/sqlplus *,/u01/app/oracle/product/11.2.0/db_1/bin/lsnrctl *,/bin/su *
注释掉/etc/sudoer文件如下

#Defaults    requiretty
修改/etc/oratab修改成如下 注将N改成Y

orcl:/u01/app/oracle/product/11.2.0/db_1:Y

在/etc/init.d创建文件oracle_service
文件添加权限

chmod a+x oracle_service
添加启动项

chkconfig --add oracle_service
chkconfig oracle_service on
