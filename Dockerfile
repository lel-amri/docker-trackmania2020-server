FROM docker.io/debian:bullseye-slim

LABEL org.opencontainers.image.title="Trackmania 2020 Server" \
      org.opencontainers.image.description="Server for the 2020 remake of Trackmania developed by Nadeo and published by Ubisoft." \
      org.opencontainers.image.authors="Léo El Amri <leo@superlel.me>"

ARG EXPECTED_FILE_ETAG="\"9d4e9cf2d15b37e648f9fcdcb5efbcfc-65\""

RUN set -eux \
    ; apt-get -y update \
    ; apt-get -y install curl python3-minimal unzip \
# Check that the file ETag is the expected ETag
    ; test "$(curl -Isi "https://nadeo-download.cdn.ubi.com/trackmania/TrackmaniaServer_Latest.zip" | python3 -c "import sys;from email.parser import BytesParser;print(BytesParser().parsebytes(sys.stdin.buffer.read().split(b\"\\r\\n\", 1)[1])[\"ETag\"])")" = "$EXPECTED_FILE_ETAG" \
    ; curl -so "/TrackmaniaServer.zip" "https://nadeo-download.cdn.ubi.com/trackmania/TrackmaniaServer_Latest.zip" \
    ; adduser --system --no-create-home --disabled-password --disabled-login trackmania \
    ; mkdir -p "/opt/trackmania" \
    ; unzip "/TrackmaniaServer.zip" -d "/opt/trackmania" \
    ; rm -rf "/opt/trackmania/RemoteControlExamples" \
    ; rm -f "/opt/trackmania/TrackmaniaServer.exe" \
    ; mv "/opt/trackmania/UserData/Config/dedicated_cfg.default.txt" "/opt/trackmania/UserData/Config/dedicated_cfg.xml" \
    ; mv "/opt/trackmania/UserData/Maps/MatchSettings/example.txt" "/opt/trackmania/UserData/Maps/MatchSettings/game_settings.xml" \
    ; chmod -R u=rwX,g=rwX,o=rX "/opt/trackmania" \
    ; find "/opt/trackmania" -type f -perm "/u=x,g=x,o=x" -exec chmod -x {} + \
    ; chmod +x "/opt/trackmania/TrackmaniaServer" \
    ; chown -R trackmania:nogroup "/opt/trackmania" \
    ; rm -f "/TrackmaniaServer.zip" \
    ; apt-get -y autoremove --purge curl python3-minimal unzip

WORKDIR "/opt/trackmania"

EXPOSE 2350/tcp 2350/udp 5000/tcp

VOLUME ["/opt/trackmania/UserData", "/opt/trackmania/CommonData", "/opt/trackmania/Logs"]

USER trackmania:nogroup

CMD ["/opt/trackmania/TrackmaniaServer", "/nodaemon", "/dedicated_cfg=dedicated_cfg.xml", "/game_settings=MatchSettings/game_settings.xml"]
