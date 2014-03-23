# Usage: ip_for.sh postgresql_server
CONTAINER_ID=$(docker ps | grep ${1} | awk '{print $1}')
IP=$(docker inspect $CONTAINER_ID | python -c 'import json,sys;obj=json.load(sys.stdin);print obj[0]["NetworkSettings"]["IPAddress"]')
echo $IP
