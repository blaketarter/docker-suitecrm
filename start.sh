#!/bin/bash

# Run Confd to make config files
#/usr/local/bin/confd -onetime -backend env

# Export all env vars containing "_" to a file for use with cron jobs
printenv | grep \_ | sed 's/^\(.*\)$/export \1/g' | sed 's/=/=\"/' | sed 's/$/"/g' > /root/project_env.sh
chmod +x /root/project_env.sh

# Add cron jobs
if [[ -n "$GIT_REPO" ]] ; then
  sed -i "/drush/s/^\w*/$(echo $GIT_REPO | md5sum | grep -P '[0-5][0-9]' -o | head -1)/" /root/crons.conf
fi
if [[ ! -n "$PRODUCTION" || $PRODUCTION != "true" ]] ; then
  sed -i "/git pull/s/[0-9]\+/5/" /root/crons.conf
fi

# Clone repo to container
git clone --depth=1 -b $GIT_BRANCH $GIT_REPO /var/www/site/

# Create and symlink files folders
mkdir -p /mnt/sites-files/uploads
chown www-data:www-data -R /mnt/sites-files/
ln -s /mnt/sites-files/uploads $APACHE_DOCROOT/

# Install appropriate apache config and restart apache
if [[ -n "$WWW" &&  $WWW = "true" ]] ; then
  cp /root/wwwsite.conf /etc/apache2/sites-enabled/000-default.conf
fi

# Import starter.sql, if needed
/root/mysqlimport.sh

# Load configs
/root/load-configs.sh

crontab /root/crons.conf
/usr/bin/supervisorctl restart apache2

