#!/usr/bin/env bash
# vim: noet

function main() {
	su -l vagrant <<-END_VAGRANT_USER
		pushd \$HOME

		pushd foreman

		git remote rename origin upstream
		git remote add fork git@github.com:komidore64/foreman.git
		git fetch --all --prune

		rvm --force gemset empty
		rm Gemfile.lock
		echo "2.2.1" > .ruby-version
		echo "foretello" > .ruby-gemset
		rvm gemset create foretello
		rvm_is_not_a_shell_function=0 rvm use 2.2.1@foretello

		cat > bundler.d/debug.local.rb <<-END_OF_DEBUG_LOCAL_RB
			gem 'pry'
			gem 'pry-byebug'
			gem 'pry-stack_explorer'
		END_OF_DEBUG_LOCAL_RB

		bundle install

		rake katello:reset && rake katello:reindex && rake apipie:cache

		popd # foreman

		pushd katello

		git remote rename origin upstream
		git remote add fork git@github.com:komidore64/katello.git
		git fetch --all --prune

		popd # katello

		popd # \$HOME
	END_VAGRANT_USER

}

main
