ARG BASE_IMAGE_TAG

FROM wodby/php:${BASE_IMAGE_TAG}

USER root

ENV WP_CLI_VERSION="2.0.0"

RUN set -ex; \
    \
    apk add --no-cache -t .fetch-deps gnupg; \
    \
    cd /tmp; \
    url="https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar"; \
    curl -o wp.phar -fSL "${url}"; \
    curl -o wp.phar.asc -fSL "${url}.asc"; \
    \
    GPG_KEYS=63AF7AA15067C05616FDDD88A3A2E8F226F0BC06 gpg_verify /tmp/wp.phar.asc /tmp/wp.phar; \
    \
    sha512="18c15c792a0747e434f70fb74f8d82dbc6dc504bd6238a4928859430129f12d88d829a1f37203c30813eb5f4d2c69f4e40aa15c74d9c6f01343052f01842463b"; \
	echo "${sha512} *wp.phar" | sha512sum -c -; \
	\
    chmod +x wp.phar; \
    mv wp.phar /usr/local/bin/wp; \
    \
    url="https://raw.githubusercontent.com/wp-cli/wp-cli/v${WP_CLI_VERSION}/utils/wp-completion.bash"; \
    curl -o /usr/local/include/wp-completion.bash -fSL "${url}"; \
    cd /home/wodby; \
    echo "source /usr/local/include/wp-completion.bash" | tee -a .bash_profile .bashrc .shrc; \
    \
    if [[ -z "${PHP_DEV}" ]]; then \
        echo "$(cat /etc/sudoers.d/wodby), /usr/local/bin/init_wordpress" > /etc/sudoers.d/wodby; \
    fi; \
    \
    mv /usr/local/bin/actions.mk /usr/local/bin/php.mk; \
    \
    apk del --purge .fetch-deps; \
    rm -rf /var/cache/apk/* /tmp/*

USER wodby

COPY templates /etc/gotpl/
COPY bin /usr/local/bin
COPY init /docker-entrypoint-init.d/