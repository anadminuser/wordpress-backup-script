#!/bin/bash
start=`date +%s`
time=$(date +"%T")
echo "Started backup process at $time"

echo "Site config files found:"
find ./public_html/ -type f -name "wp-config.php"


if [ -d ~/script_backup_dir ] ; then 
    echo "backing up in ~/script_backup_dir"
else 
    mkdir ~/script_backup_dir
    echo "Creating ~/script_backup_dir/"
fi 
i=0
echo ""
for n in $( find ./public_html/ -type f -name "wp-config.php" )
do
    db_name=`grep 'DB_NAME' $n | sed "s/define(\s*'DB_NAME', '//g" | sed "s/'\s*);//g" | tr '\r' '\n'`
    db_user=`grep 'DB_USER' $n | sed "s/define(\s*'DB_USER', '//g" | sed "s/'\s*);//g" | tr '\r' '\n'`
    db_pass=`grep 'DB_PASSWORD' $n | sed "s/define(\s*'DB_PASSWORD', '//g" | sed "s/'\s*);//g" | tr '\r' '\n'`
    db_host=`grep 'DB_HOST' $n | sed "s/define(\s*'DB_HOST', '//g" | sed "s/'\s*);//g" | tr '\r' '\n'`
    name=`echo $n | sed 's/\.\/public_html\///g' | sed 's/\/wp-config\.php//g' | tr '\r' '\n'`
    home=`dirname $n | tr '\r' '\n'`
    
    echo "Backing up $name"

    mysqldump --no-tablespaces -u$db_user -p$db_pass -h$db_host $db_name > $home/wp-content/sql_dump.sql

    if [ -f $home/wp-content/sql_dump.sql ] ; then 
        echo "Database backup was created for $name"
    else 
        echo "Datbase backup was not created for $name. Something went wrong."
    fi 
    cd $home
    zip -rq $name.zip .
    mv $name.zip ~/script_backup_dir/
    # cd ~/script_backup_dir
    # zip -qr "$name.zip" ~/$home/. 
    if [ -f ~/script_backup_dir/$name.zip ] ; then 
        echo "Backup created for $name"
    else 
        echo "Backup was not created for $name. Something went wrong."
    fi 
    
    cd ~
    ((i=i+1))
    echo "Backups created: $i"
    echo ""
done
end=`date +%s`
runtime=$((end-start))
echo "$i backups were created in $runtime seconds."
