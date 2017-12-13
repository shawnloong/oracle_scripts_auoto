####################################################################################
## Date:2017-07-07																##
## Author: shawnloong															 ##
## Version:1.1																	##
# chkconfig: 2345 10 90														   ##
####################################################################################
#!/bin/bash
USER=`id|cut -d "(" -f2|cut -d ")" -f1`
ORACLE_SID=orcl
ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
LOG_FILE=/tmp/oracle_service.log
Listen_name=LISTENER
export ORACLE_SID ORACLE_HOME LOG_FILE Listen_name

function green_echo(){
	echo -e "\e[40;32;1m$1\e[0m"
}

function red_echo(){
	echo -e "\e[40;31;1m$1\e[0m"
}

function yellow_echo(){
	echo -e "\e[40;33;1m$1\e[0m"
}

#if [ "$USER" != "oracle" ];then
#   red_echo "You must Run with oracle Account" 
#   exit
#fi 

start_listener(){
  sudo su - oracle -c "$ORACLE_HOME/bin/lsnrctl start $Listen_name" >> $LOG_FILE 2>&1
  if [ $? -eq 0 ];then
    green_echo "Bringing up listener: $Listen_name [ Start ]"
  else
    red_echo "Bringing Start listener: $Listen_name Failure,Please check logfile $LOG_FILE"
  fi
}

stop_listener(){
  sudo su - oracle -c "$ORACLE_HOME/bin/lsnrctl stop $Listen_name" >> $LOG_FILE 2>&1
  if [ $? -eq 0 ];then
    green_echo "Bringing stop listener: $Listen_name [ Stop ]"
  else
    read_eacho "Bringing stop listener: $Listen_name Failure,Please check logfile $LOG_FILE"
  fi
}  

start_db(){
 sudo su - oracle -c "$ORACLE_HOME/bin/sqlplus -S /nolog <<EOF
   conn / as sysdba
   startup nomount;
   alter database mount;
   alter database open;
   exit;
EOF">> $LOG_FILE 2>&1
ecount=`tail -10 /tmp/oracle_service.log |grep ORA-|wc -l`
if [[ $? -eq 0 && $ecount -eq 0 ]];then
  green_echo "Bringing up oracle instance $ORACLE_SID:[ Start ]"
else
  red_echo "Bringing up oracle instance $ORACLE_SID Failure,Please check logfile $LOG_FILE"
fi
}

stop_db() {
 sudo su - oracle -c "$ORACLE_HOME/bin/sqlplus -S /nolog <<EOF
 conn / as sysdba
 alter system switch logfile;
 alter system checkpoint;
 alter system checkpoint;
 alter system checkpoint;
 alter system checkpoint;
 alter system checkpoint;
 shutdown immediate;
 exit;
EOF">> $LOG_FILE 2>&1
 pcount=`ps -ef |grep ora_smon_$ORACLE_SID|grep -v grep |wc -l`
 if [[ $? -eq 0 && $pcount -eq 0 ]]
 then
   green_echo "Bringing stop oracle instance $ORACLE_SID:[ Stop ]"
 else
   red_echo "Bringing stop oracle instance $ORACLE_SID failure,Please check logfile $LOG_FILE"
fi
}

start(){
  if [ `ps -ef |grep $Listen_name|grep -v grep |wc -l` -eq 0 ];then
    #echo `ps -ef |grep $Listen_name|grep -v grep |wc -l`
    start_listener
  else
    yellow_echo "Listener already [ start ]"
  fi

  if [ `ps -ef |grep ora_smon_$ORACLE_SID|grep -v grep |wc -l` -eq 0 ];then
    start_db
  else
    yellow_echo "Instance $ORACLE_SID already [ start ]"
  fi
}

stop(){
  if [ `ps -ef |grep $Listen_name|grep -v grep |wc -l` -eq 1 ];then
    stop_listener
  else
    yellow_echo "Listener already  [ stop ]"
  fi

  if [ `ps -ef |grep ora_smon_$ORACLE_SID|grep -v grep |wc -l` -eq 1 ];then
    stop_db
  else
    yellow_echo "Instance $ORACLE_SID already [ stop ]"
  fi
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  restart)
        stop
        sleep 10
        start
        ;;
  *)
        red_echo "Usage: $0 {Start|Stop|Restart}"
esac
exit 0
