# Compile stage
FROM golang:1.13.5-alpine AS build-env
ENV CGO_ENABLED 0
ADD . /go/src/hello

# The -gcflags "all=-N -l" flag helps us get a better debug experience
RUN go build -gcflags "all=-N -l" -o /server hello

# Compile Delve
RUN apk add --no-cache git
RUN go get github.com/derekparker/delve/cmd/dlv

# Final stage
FROM alpine:3.7
# Port 8080 belongs to our application, 40000 belongs to Delve
EXPOSE 8080 40000

# Allow delve to run on Alpine based containers.
RUN apk add --no-cache libc6-compat

WORKDIR /
COPY --from=build-env /server /
COPY --from=build-env /go/bin/dlv /

#CMD ["/server"]
# Run delve
CMD ["/dlv", "--listen=:40000", "--headless=true", "--api-version=2", "exec", "/server"]
