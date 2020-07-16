FROM alpine AS build

WORKDIR /usr/src/ndppd
COPY . .

# Build Ndppd
RUN apk add make g++ linux-headers patch \
	&& patch src/logger.cc < patch/src/logger.patch \
	&& make && make install \
	&& mv entrypoint.sh /usr/sbin/ \
	&& chmod +x /usr/sbin/entrypoint.sh

FROM alpine AS container

COPY --from=build /usr/src/ndppd/ndppd /usr/sbin/

#COPY --from=build /usr/src/ndppd/ndppd.1.gz /share/man/man1
#COPY --from=build /usr/src/ndppd/ndppd.conf.5.gz /share/man/man5
COPY --from=build /usr/sbin/entrypoint.sh /usr/sbin/entrypoint.sh

RUN apk --no-cache add libc6-compat libgcc libstdc++

CMD ["/usr/sbin/entrypoint.sh"]