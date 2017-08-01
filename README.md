# dev-parity-builds
DevOps task for latest parity 1.8.0

git clone https://github.com/nzelenkov/dev-parity-builds.git
cd dev-parity-builds/docker/ubuntu/
docker build -f docker/ubuntu/Dockerfile --tag nzelenkov/parity:v1.8.0 .