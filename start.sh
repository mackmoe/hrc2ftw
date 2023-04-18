#!/bin/bash
set -x

if [ -z "$PROJECT_ENVIRONMENT" ]; then
   echo "PROJECT_ENVIRONMENT not set, assuming Development"
   PROJECT_ENVIRONMENT="Development"
fi

echo "fixing permissions..."
chown -R www-data:www-data /var/www && \
chmod -R 0755 /var/www/html && \
chgrp -R www-data /var/www/html

echo "Starting shell..."
# start a shell
/bin/bash
