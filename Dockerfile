FROM alpine:3.7 as builder

RUN set -eux; apk add --no-cache --virtual .diod-build-deps \
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
	apk del .diod-build-deps

FROM alpine:3.7

COPY --from=builder /tmp/diod/diod/diod /bin/diod

RUN set -eux; apk add --no-cache \
	attr \
	libcap

VOLUME /export

ENTRYPOINT ["/bin/diod", "-f"]

CMD ["-e", "/export", "-n", "-L", "stderr"]
