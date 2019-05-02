FROM alpine:3.9 as builder

RUN set -eux; apk add --no-cache --virtual .diod-build-dependencies \
		automake autoconf \
		attr-dev \
		binutils \
		fortify-headers \
		gcc \
		git \
		libcap-dev \
		libc-dev \
		make \
		; \
	git clone https://github.com/chaos/diod /tmp/diod; \
	cd /tmp/diod; \
	sed -i '                        \
		s,^[ \t]*diod \\,diod,g;    \
		s,utils \\,,;               \
		s,scripts \\,,;             \
		s,etc \\,,;                 \
		s,tests,,;                  \
	' Makefile.am; \
	./autogen.sh; \
	./configure; \
	make; \
	apk del .diod-build-dependencies

FROM alpine:3.9

COPY --from=builder /tmp/diod/diod/diod /bin/diod

RUN set -eux; apk add --no-cache \
	attr \
	libcap

VOLUME /export
EXPOSE 5640

ENTRYPOINT ["diod", "--foreground", "--listen", "0.0.0.0:5640"]
CMD ["--export", "/export", "--no-auth", "--logdest", "stderr"]
