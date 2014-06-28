mysql-dump-all() {
    if [[ ! -z $1 ]];
        then
            dumpname=$1
    else
        dumpname="alldb"
    fi

    print -P "${message_default}Dumping all databases to ${dumpname}.sql$FX[reset]"
    mysqldump -uroot -p --all-databases > $dumpname.sql
}

mysql-restore() {
    if [[ ! -z $1 ]];
        then
            dumpname=$1
    else
        dumpname="alldb"
    fi

    print -P "${message_default}Restoring ${dumpname}.sql$FX[reset]"
    mysql -u root -p < $dumpname.sql
}
