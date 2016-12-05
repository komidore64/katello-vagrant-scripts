#!/usr/bin/env bash
# vim: noet

PKG_GROUPS=(
	[0]="Development Tools"
)

PACKAGES=(
	bc
	time
	vim
	git
	tig
	tmux
	tito
	koji
	mock
	git-annex
	rpmdevtools
	libcurl-devel
	scl-utils-build
	ack
	mysql-devel
	npm
)

function main () {
	local i

	sudo yum update -y

	for i in $( seq 0 $(( ${#PKG_GROUPS[@]} - 1 )) ); do
		sudo yum groupinstall -y ${PKG_GROUPS[${i}]}
	done

	for i in $( seq 0 $(( ${#PACKAGES[@]} - 1 )) ); do
		sudo yum install -y ${PACKAGES[${i}]}
	done
}

set -x
main
