ARG PHP_VERSION=8.0.15


FROM php:${PHP_VERSION}-cli-alpine

LABEL project="nbgrp/auditor" \
      version="0.4.0" \
      maintainer="amenshchikov@gmail.com"

ENV COMPOSER_HOME /composer
ENV COMPOSER_ALLOW_SUPERUSER 1

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/
COPY docker-entrypoint /usr/local/bin/
COPY tools /tools

RUN set -ex; \
    apk update; \
    \
    apk add ncurses-libs; \
    \
    install-php-extensions \
        amqp \
        apcu \
        ast \
        bcmath \
        exif \
        ffi \
        gd \
        gmp \
        igbinary \
        imagick \
        intl \
        ldap \
        mbstring \
        memcache \
        opcache \
        pdo_pgsql \
        redis \
        uuid \
    ; \
    \
    RUNTIME_DEPS="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
        | tr ',' '\n' \
        | sort -u \
        | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )"; \
    apk add --no-cache $RUNTIME_DEPS; \
    \
    ln -s ${PHP_INI_DIR}/php.ini-production ${PHP_INI_DIR}/php.ini; \
    printf "memory_limit = -1\n" >  $PHP_INI_DIR/conf.d/memory_unlimit.ini; \
    \
    wget -O /usr/local/bin/local-php-security-checker https://github.com/fabpot/local-php-security-checker/releases/download/v1.0.0/local-php-security-checker_1.0.0_linux_amd64; \
    chmod +x /usr/local/bin/local-php-security-checker; \
    \
    chmod +x /usr/local/bin/docker-entrypoint; \
    \
    composer self-update; \
    composer global require \
        ergebnis/composer-normalize \
        qossmic/deptrac-shim \
        phpro/grumphp-shim \
    --no-scripts --no-progress; \
    \
    composer install --working-dir=/tools/phan --prefer-dist --no-scripts --no-progress; \
    composer install --working-dir=/tools/php-cs-fixer --prefer-dist --no-scripts --no-progress; \
    composer install --working-dir=/tools/phpcs --prefer-dist --no-scripts --no-progress; \
    composer install --working-dir=/tools/phpmd --prefer-dist --no-scripts --no-progress; \
    composer install --working-dir=/tools/phpmnd --prefer-dist --no-scripts --no-progress; \
    composer install --working-dir=/tools/phpstan --prefer-dist --no-scripts --no-progress; \
    composer install --working-dir=/tools/psalm --prefer-dist --no-scripts --no-progress

ENV PATH /composer/vendor/bin:/tools/phan/vendor/bin:/tools/php-cs-fixer/vendor/bin:/tools/phpcs/vendor/bin:/tools/phpmd/vendor/bin:/tools/phpmnd/vendor/bin:/tools/phpstan/vendor/bin:/tools/psalm/vendor/bin:$PATH

ENTRYPOINT [ "docker-entrypoint" ]
CMD [ "grumphp", "run" ]
