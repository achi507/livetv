FROM golang:alpine AS builder
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && apk update && apk --no-cache add build-base
WORKDIR /go/src/github.com/zjyl1994/livetv/
COPY . .
RUN GOPROXY="https://goproxy.cn" GO111MODULE=on go build -o livetv .

FROM alpine:latest
RUN apk --no-cache add ca-certificates tzdata python3 libc6-compat libgcc libstdc++ && \
    ln -s /usr/bin/python3 /usr/local/bin/python && \
    wget -q https://github.com/ytdl-org/youtube-dl/releases/download/2021.12.17/youtube-dl -O /usr/local/bin/youtube-dl && \
    rm -rf /var/cache/apk/* && \
    chmod 777 /usr/local/bin/youtube-dl

WORKDIR /root
COPY --from=builder /go/src/github.com/zjyl1994/livetv/view ./view
COPY --from=builder /go/src/github.com/zjyl1994/livetv/assert ./assert
COPY --from=builder /go/src/github.com/zjyl1994/livetv/.env .
COPY --from=builder /go/src/github.com/zjyl1994/livetv/livetv .
EXPOSE 9000
VOLUME ["/root/data"]
CMD ["./livetv"]
