#!/bin/sh

bool=false

while getopts d opt; do
  case $opt in
  d)
    echo "running in daemon"
    bool=true
    shift
    ;;
  ?)
    echo "$opt is an invalid option"
    ;;
  esac
done

BIN_DIR=$(dirname $0)
BIN_DIR=$(
  cd "$BIN_DIR"
  pwd
)
# 安装包部署的目录
HOME=$BIN_DIR/..
PID=$BIN_DIR/server.pid

export CONF_DIR=$HOME/conf
export LIB_DIR=$HOME/lib/
export LOG_DIR=$HOME/logs

# 判断第一个参数包含第二个参数开头的字符串
function contain() {
  local array=$1
  for item in ${array[*]}; do
    if [[ $2 =~ ^"${item}-".* ]]; then
      echo $2
      return 0
    fi
  done
  return 1
}

if [ $1 = "standalone" ]; then
	standalone_exclude_jars=("spring-boot-starter-webflux" "spring-webflux" "spring-cloud-gateway-server" "spring-cloud-starter-gateway")
	standalone_cp=$CONF_DIR
	for tmp in $(ls $LIB_DIR); do
	  contain "${standalone_exclude_jars[*]}" $tmp
	  res=$(echo $?)
	  if [ $res = "1" ]; then
		standalone_cp=$standalone_cp:$LIB_DIR$tmp #不包含在其中就拼接
	  fi
	done
#  echo $standalone_cp
  java -Dspring.profiles.active=standalone -classpath $standalone_cp com.gitee.freakchicken.dbapi.DBApiStandalone


elif [ $1 = "manager" ]; then
	manager_exclude_jars=("spring-boot-starter-webflux" "spring-webflux" "spring-cloud-gateway-server" "spring-cloud-starter-gateway")
	manager_cp=$CONF_DIR
	for tmp in $(ls $LIB_DIR); do
	  contain "${manager_exclude_jars[*]}" $tmp
	  res=$(echo $?)
	  if [ $res = "1" ]; then
		manager_cp=$manager_cp:$LIB_DIR$tmp #不包含在其中就拼接
	  fi
	done
#  echo $manager_cp
  java -Dspring.profiles.active=manager -classpath $manager_cp com.gitee.freakchicken.dbapi.DBApiManager

elif [ $1 = "apiServer" ]; then
	api_exclude_jars=("spring-boot-starter-webflux" "spring-webflux" "spring-cloud-gateway-server" "spring-cloud-starter-gateway")
	api_cp=$CONF_DIR
	for tmp in $(ls $LIB_DIR); do
	  contain "${api_exclude_jars[*]}" $tmp
	  res=$(echo $?)
	  if [ $res = "1" ]; then
		api_cp=$api_cp:$LIB_DIR$tmp #不包含在其中就拼接
	  fi
	done
#  echo $api_cp
  java -Dspring.profiles.active=apiServer -classpath $api_cp com.gitee.freakchicken.dbapi.DBApiApiServer

elif [ $1 = "gateway" ]; then
	exclude_jars=("spring-boot-starter-tomcat" "spring-boot-starter-web" "tomcat-embed-websocket" "tomcat-embed-core" "spring-webmvc")
	gateway_cp=$CONF_DIR
	for tmp in $(ls $LIB_DIR); do
	  contain "${exclude_jars[*]}" $tmp
	  res=$(echo $?)
	  if [ $res = "1" ]; then
		gateway_cp=$gateway_cp:$LIB_DIR$tmp #不包含在其中就拼接
	  fi
	done
#  echo $gateway_cp
  java -Dspring.profiles.active=gateway -classpath $gateway_cp com.gitee.freakchicken.dbapi.DBApiGateWay

else
  echo "parameter invalid"
fi
