#!/bin/bash

# Set up Docker daemon
sudo yum -y update
sudo yum -y install docker
# Allows ec2-user to run docker commands
sudo usermod -a -G docker ec2-user
service docker start

# Configure redis
cat << EOF > ~/redis.conf
requirepass ${redis_password}
bind 0.0.0.0
protected-mode yes
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize no
supervised no
pidfile /var/run/redis_6379.pid
loglevel notice
logfile ""
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir ./
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
slave-priority 100
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
slave-lazy-flush no
appendonly no
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble no
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
EOF

# Use recommended optimizations for running Redis.
# Disable transparent huge pages
sudo echo never > /sys/kernel/mm/transparent_hugepage/enabled
# Allow allocation of non-existent virtual memory
sudo sysctl vm.overcommit_memory=1

# Run Redis
docker run -v ~/redis.conf:/usr/local/etc/redis/redis.conf -p 6379:6379 --name cacheserver \
redis:4.0.10 redis-server /usr/local/etc/redis/redis.conf