#!/bin/bash

set -e
set -u

# 创建用户和数据库的函数
function create_user_and_database() {
    local database=$1
    echo "  正在创建用户和数据库 '$database'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
        CREATE USER $database;
        CREATE DATABASE $database;
        GRANT ALL PRIVILEGES ON DATABASE $database TO $database;
EOSQL
}

# 如果指定了多数据库，则创建它们
if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
    echo "开始创建多个数据库: $POSTGRES_MULTIPLE_DATABASES"
    for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
        create_user_and_database $db
    done
    echo "多数据库已创建"
fi

# 如果列表中不存在 openwebui 数据库，则创建它
if [[ ! "$POSTGRES_MULTIPLE_DATABASES" =~ "openwebui" ]]; then
    create_user_and_database "openwebui"
    echo "OpenWebUI 数据库已创建"
fi