#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y mysql-server

cat >/etc/mysql/mysql.conf.d/mysqld.cnf <<'EOF'
[mysqld]
bind-address = 0.0.0.0
port = 3306
server-id = 1
log_bin = mysql-bin
binlog_format = ROW
binlog_row_image = FULL
gtid_mode = ON
enforce_gtid_consistency = ON
log_replica_updates = ON
sync_binlog = 1
innodb_flush_log_at_trx_commit = 1
skip_name_resolve = ON
read_only = OFF
super_read_only = OFF
EOF

systemctl restart mysql

repl_password="${1:-}"
if [[ -z "$repl_password" ]]; then
  echo "Usage: $0 <replication-password>" >&2
  exit 1
fi

mysql <<SQL
SET sql_log_bin = 0;
CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED BY '${repl_password}';
ALTER USER 'repl'@'%' IDENTIFIED BY '${repl_password}';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
SET sql_log_bin = 1;
SQL
