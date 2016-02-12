## */5 * * * * purge_queue_script.sh
source config.conf 

now="$(date)"
echo '[ '$now' ] Starting Queue :'$queuename' watch routine' >> script_log.log

purge_address="http://"$server_address":8181/hawtio/jolokia/exec/org.apache.activemq:type=Broker,brokerName=amq,destinationType=Queue,destinationName="$queuename"/purge()"
queue_size_address="http://"$server_address":8181/hawtio/jolokia/read/org.apache.activemq:type=Broker,brokerName=amq,destinationType=Queue,destinationName="$queuename"/QueueSize"

number_msgs=$( curl --user $hawtio_user:$hawtio_password --silent $queue_size_address --stderr - | grep -Po  'value.*' | cut -d':' -f 2 | cut -d',' -f 1)

if [ $number_msgs == $threshold ] ; then 
	curl --user $hawtio_user:$hawtio_password --silent $purge_address --stderr -
	echo $number_msgs' messages were purged' >> script_log.log
else
	echo $number_msgs' founded' >> script_log.log
fi

