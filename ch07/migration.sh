
#!/usr/bin/env bash

set -euo pipefail

### 全局

SOURCE_HOST=192.168.2.104:37017
TARGET_HOST=192.168.2.104:47017
FILE_SUFFIX=".csv"


### admin 库

DATABASE_NAME=admin
JSON_PATH=/mgdata/json/${DATABASE_NAME}
COMP_PATH=/mgdata/comp/${DATABASE_NAME}
COLLECTIONS_NAME=("traderDay")
USER_NAME=plumzero
PASSWORD=mypassword

mkdir -p ${JSON_PATH}
mkdir -p ${COMP_PATH}

# mongoexport --host 192.168.2.104:37017 -u plumzero -p mypassword --authenticationDatabase admin -d admin -c traderDay --type json --out /mgdata/json/admin/traderDay.json
# mongoimport --host 192.168.2.104:47017 -u plumzero -p mypassword --authenticationDatabase admin -d admin -c traderDay --type json  --file /mgdata/json/admin/traderDay.json

for coll in ${COLLECTIONS_NAME[@]}
do
    mongoexport --host ${SOURCE_HOST} -u ${USER_NAME} -p ${PASSWORD} --authenticationDatabase admin -d admin -c $coll --type json --out ${JSON_PATH}/$coll${FILE_SUFFIX}
    mongoimport --host ${TARGET_HOST} -u ${USER_NAME} -p ${PASSWORD} --authenticationDatabase admin -d admin -c $coll --type json  --file ${JSON_PATH}/$coll${FILE_SUFFIX}

    echo mongoexport --host ${TARGET_HOST} -u ${USER_NAME} -p ${PASSWORD} --authenticationDatabase admin -d admin -c $coll --type json --out ${COMP_PATH}/$coll${FILE_SUFFIX}
    mongoexport --host ${TARGET_HOST} -u ${USER_NAME} -p ${PASSWORD} --authenticationDatabase admin -d admin -c $coll --type json --out ${COMP_PATH}/$coll${FILE_SUFFIX}
    hash_source=`md5sum ${JSON_PATH}/$coll${FILE_SUFFIX} | awk '{ print $1; }'`
    hash_target=`md5sum ${COMP_PATH}/$coll${FILE_SUFFIX} | awk '{ print $1; }'`
    echo "==>" $hash_source
    echo "==>" $hash_target
done

# mongo --host ${TARGET_HOST} -u ${USER_NAME} -p ${PASSWORD} --authenticationDatabase admin admin --eval 'printjson(db.traderDay.find().count())'
