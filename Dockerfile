
FROM docker.io/library/vault:1.12.2
# -----------------------------------------------------------------------------
#                                                                    [ LABELS ]
# -----------------------------------------------------------------------------
LABEL   author="0ghny"
# -----------------------------------------------------------------------------
#                                                                     [ BUILD ]
# -----------------------------------------------------------------------------
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY lib /usr/local/lib
COPY bin/vault-operator /usr/local/bin/vault-operator
RUN apk add --no-cache \
    curl && \
    chmod +x /docker-entrypoint.sh && \
    chmod +x /usr/local/bin/vault-operator && \
    mkdir -p /vault/unlocker && \
    chown -R vault:vault /vault
VOLUME [/vault/logs, /vault/unlocker]
# -----------------------------------------------------------------------------
#                                                                [ ENTRYPOINT ]
# -----------------------------------------------------------------------------
ENTRYPOINT ["/docker-entrypoint.sh"]
