#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

primary_private_ip="${1:-}"
repl_password="${2:-}"

if [[ -z "$primary_private_ip" || -z "$repl_password" ]]; then
  echo "Usage: $0 <primary-private-ip> <replication-password>" >&2
  exit 1
fi

apt-get update -y
apt-get install -y mysql-server

cat >/etc/mysql/mysql.conf.d/mysqld.cnf <<'EOF'
[mysqld]
bind-address = 0.0.0.0
port = 3306
server-id = 2
log_bin = mysql-bin
binlog_format = ROW
binlog_row_image = FULL
gtid_mode = ON
enforce_gtid_consistency = ON
log_replica_updates = ON
relay_log = relay-bin
sync_binlog = 1
innodb_flush_log_at_trx_commit = 1
skip_name_resolve = ON
read_only = ON
super_read_only = ON
EOF

systemctl restart mysql

mysql <<SQL
STOP REPLICA;
RESET REPLICA ALL;
RESET MASTER;
CHANGE REPLICATION SOURCE TO
  SOURCE_HOST = '${primary_private_ip}',
  SOURCE_USER = 'repl',
  SOURCE_PASSWORD = '${repl_password}',
  SOURCE_PORT = 3306,
  SOURCE_AUTO_POSITION = 1,
  GET_SOURCE_PUBLIC_KEY = 1;
START REPLICA;
SET GLOBAL read_only = ON;
SET GLOBAL super_read_only = ON;
SQL
