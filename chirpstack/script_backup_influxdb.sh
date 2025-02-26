#!/bin/bash
dest_folder="/var/backup_influxdb"
logger "Backup influxdb to ${dest_folder}"
token="uk8yS3KzVkhaF0cf/CFWy044i8qpNTenEKGCA3SgWK8="
rm -rf "${dest_folder}"
sudo docker exec iot-app-influxdb-1 sh -c 'rm -rf /root/influx_backup'
sudo docker exec iot-app-influxdb-1 influx backup /root/influx_backup -t "${token}"
sudo docker cp iot-app-influxdb-1:/root/influx_backup "${dest_folder}"
sudo chown -R almalinux "${dest_folder}"
