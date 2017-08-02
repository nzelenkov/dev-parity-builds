#!/bin/bash
set -e

SCRIPT_NAME=$(basename "$0")

parity_build_help()
{
	echo "
	Usage: $SCRIPT_NAME --rust-version <rust-version> --parity-version <parity-version>

	DESCRIPTION
		--rust-version <rust-version>
			The rust version to use for the build. Accepted values: stable|beta|nightly
		--parity-version <parity-version>
			The parity version to build. Accepted values: stable|beta|master
	"
}

parity_build()
{
    echo "###"
    echo "### Creating a DigitalOcean droplet with Ubuntu 16.04 and installing docker 17.05"
    echo "###"
    docker-machine create --driver digitalocean --digitalocean-image ubuntu-16-04-x64 --digitalocean-size 2gb --engine-install-url=https://releases.rancher.com/install-docker/17.05.sh --digitalocean-access-token $DOTOKEN dckr-parity-00001

    echo "###"
    echo "### Clone parity branch based on arguments, build the docker image and deploy the artifact to https://transfer.sh public URL"
    echo "###"
    docker-machine ssh dckr-parity-00001 "git clone https://github.com/paritytech/parity && cd parity && git fetch && git checkout $parityVersion && sed -i -e 's/ubuntu:14.04/ubuntu:16.04/g' docker/ubuntu/Dockerfile && sed -i -e 's/sh -s -- -y/& \&\& \/root\/.cargo\/bin\/rustup default $rustVersion \&\& \/root\/.cargo\/bin\/rustup update/g' docker/ubuntu/Dockerfile  && docker build -f docker/ubuntu/Dockerfile --tag nzelenkov/parity:v1.8.0 . && docker run --entrypoint curl nzelenkov/parity:v1.8.0 -sS --upload-file /build/parity/target/release/parity https://transfer.sh/parity_v1.8.0"
    
    echo "###"
    echo "### Clean up docker resources"
    echo "###"
    docker-machine rm -y dckr-parity-00001
}

while test $# != 0
do
	case "$1" in
	--rust-version)
		shift
		rustVersion="$1"
	;;
	--parity-version)
		shift
		parityVersion="$1"
	;;
	*)
		break
	;;
	esac
	shift || { parity_build_help; exit 1; }
done
if test -z $rustVersion || test -z $parityVersion ; then
	parity_build_help
	exit 1
else
    rustVersions='^(stable|beta|nightly)$'
	if [[ !($rustVersion  =~ $rustVersions) ]]; then
        parity_build_help; exit 1;
	fi
    parityVersions='^(stable|beta|master)$'
	if [[ !($parityVersion  =~ $parityVersions) ]]; then
		parity_build_help; exit 1;
	fi
	parity_build
	exit 0
fi

