FROM ubuntu:focal-20241011 AS builder

RUN apt update
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:longsleep/golang-backports
RUN apt install golang-go -y

WORKDIR /app

COPY . .

RUN go build -o /simple-app


FROM ubuntu:focal-20241011

COPY --from=builder /simple-app /simple-app

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/simple-app"]