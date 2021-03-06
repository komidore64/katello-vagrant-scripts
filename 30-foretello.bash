#!/usr/bin/env bash
# vim: noet

function main() {
	su -l vagrant <<-END_VAGRANT_USER
		pushd \$HOME

		pushd foreman

		git remote set-url fork git@github.com:komidore64/foreman.git
		git branch --set-upstream-to upstream/develop
		git fetch --all --prune

		rvm --force gemset empty
		rm Gemfile.lock
		echo "2.3.0" > .ruby-version
		echo "foretello" > .ruby-gemset
		rvm gemset create foretello
		rvm_is_not_a_shell_function=0 rvm use 2.3.0@foretello

		cat > bundler.d/debug.local.rb <<-END_OF_DEBUG_LOCAL_RB
			gem 'pry'
			gem 'pry-byebug'
			gem 'pry-stack_explorer'
		END_OF_DEBUG_LOCAL_RB

		bundle install

		npm install

		rake katello:reset && rake apipie:cache && rake webpack:compile

		echo ":webpack_dev_server: false # added by vagrant startup scripts" >> config/settings.yaml

		popd # foreman

		pushd katello

		git remote set-url fork git@github.com:komidore64/katello.git
		git branch --set-upstream-to upstream/master
		git fetch --all --prune

		popd # katello

		popd # \$HOME
	END_VAGRANT_USER
}

main
