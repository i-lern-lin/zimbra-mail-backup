#CRON
#MAILTO="admin@mail.net"
# 0 6 * * *  /srv/find_rm_old_back.sh
find /mnt/outback/* -type d -mtime +2 -daystart -exec rm -rf {} \;
exit 0
