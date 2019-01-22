FROM php:7.2-alpine

# Install dev dependencies
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    curl-dev \
    imagemagick-dev \
    libtool \
    libxml2-dev

# Install production dependencies
RUN apk add --no-cache \
    nginx \
    nginx-mod-http-headers-more \
    bash \
    curl \
    g++ \
    gcc \
    git \
    imagemagick \
    libzip-dev \
    libc-dev \
    libpng-dev \
    make \
    mysql-client \
    nodejs \
    nodejs-npm \
    openssh-client \
    ca-certificates \
    rsync \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Install PECL and PEAR extensions
RUN pecl install \
    imagick

# Install and enable php extensions
RUN docker-php-ext-enable \
    imagick

RUN docker-php-ext-install \
    curl \
    iconv \
    mbstring \
    pdo \
    pdo_mysql \
    pcntl \
    tokenizer \
    xml \
    gd \
    zip \
    bcmath \
    exif

# Cleanup dev dependencies
RUN apk del -f .build-deps

# Install composer
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="./vendor/bin:$PATH"

# Install hirak/prestissimo for faster composer installs
RUN composer global require hirak/prestissimo --no-plugins --no-scripts

COPY srcs/nginx /

EXPOSE 8080

CMD ["/sbin/runit-wrapper"]
