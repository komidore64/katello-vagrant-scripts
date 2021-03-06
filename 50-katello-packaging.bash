#!/usr/bin/env bash
# vim: noet

function main() {
    usermod -aG mock vagrant

	su -l vagrant <<-END_VAGRANT_USER
		cd # confirm where we are
		rvm 2.3.0@global do gem install gem-compare

		git clone https://github.com/katello/katello-packaging.git -o upstream
		pushd katello-packaging
		git remote add fork git@github.com:komidore64/katello-packaging.git
		git branch --set-upstream-to upstream/master
		git fetch --all --prune

		git annex init
		./setup_sources.sh
		popd # katello-packaging
	END_VAGRANT_USER
}

main
