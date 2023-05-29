FROM golang:alpine
WORKDIR /workspace
RUN GOBIN=/usr/local/bin go install github.com/go-task/task/v3/cmd/task@latest
COPY Taskfile.yml ./Taskfile.yml
COPY cmd ./cmd
RUN task setup
