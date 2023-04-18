FROM jrei/systemd-ubuntu:latest AS base

# create log file
RUN touch /var/log/stdout-install.log && \
touch /var/log/stderr-install.log
RUN ln -sf /dev/stdout /var/log/stdout-install.log && \
ln -sf /dev/stdout /var/log/stderr-install.log

# Install required packages
RUN apt update && \
apt install -y --no-install-recommends \  
lsb-release ca-certificates apt-transport-https software-properties-common \
&& rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:ondrej/php && \
add-apt-repository ppa:ondrej/apache2 \
&& apt upgrade -y

RUN apt update && \
apt install -yq --no-install-recommends vim git wget curl \
apache2 php8.0 libapache2-mod-php8.0 php8.0-dev php8.0-zip php8.0-gd \
&& rm -rf /var/lib/apt/lists/*

RUN apt update -y --fix-missing && apt install -y --no-install-recommends \
libreoffice-common libreoffice-java-common default-jre \
ffmpeg clamav unoconv rar unrar p7zip-full gnuplot \
imagemagick tesseract-ocr meshlab dia pandoc \
poppler-utils nodejs libnode-dev node-gyp npm \
&& rm -rf /var/lib/apt/lists/*

# fix permissions
RUN chown -R www-data:www-data /var/www && \
chmod -R 0755 /var/www/html && \
chgrp -R www-data /var/www/html

# fix confgs
RUN sed -i "s/max_execution_time = 30/max_execution_time = 90/g" /etc/php/8.0/apache2/php.ini \
&& sed -i "s/max_input_time = 30/max_execution_time = 90/g" /etc/php/8.0/apache2/php.ini \
&& sed -i "s/max_input_time = 30/max_execution_time = 90/g" /etc/php/8.0/apache2/php.ini \
&& sed -i "s/memory_limit = 128M/memory_limit = 512M/g" /etc/php/8.0/apache2/php.ini \
&& sed -i "s/display_errors = Off/display_errors = On/g" /etc/php/8.0/apache2/php.ini \
&& sed -i "s/post_max_size = 100M/post_max_size = 3000M/g" /etc/php/8.0/apache2/php.ini \
&& sed -i "s/upload_max_filesize = 100M/upload_max_filesize = 3000M/g" /etc/php/8.0/apache2/php.ini \
&& sed -i "s/max_file_uploads = 10/max_file_uploads = 100/g" /etc/php/8.0/apache2/php.ini \
&& sed -i "s/zlib.output_compression = Off/zlib.output_compression = On/g" /etc/php/8.0/apache2/php.ini

# get source code
RUN git clone https://github.com/zelon88/HRConvert2.git /var/www/html/HRProprietary/HRConvert2 \
&& if -f ! [ /etc/rc.local ];then curl https://raw.githubusercontent.com/zelon88/HRConvert2/master/rc.local -o /etc/rc.local; fi

WORKDIR /usr/hrc2ftw
# Copy files to container
COPY *.sh .
COPY jobs/*.* ./jobs/
# Fix execute permissions on files copied over from host
RUN find . -type f -iname "*.sh" -exec chmod +x '{}' \;  

EXPOSE 80
EXPOSE 443
# Run on container startup
CMD ["./start.sh"]