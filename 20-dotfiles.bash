#!/usr/bin/env bash
# vim: noet

function main () {
	local vagrant_home=$( eval echo "~vagrant" )

	su - vagrant <<-END_VAGRANT_USER
		echo 'move to $vagrant_home'
		pushd $vagrant_home

		echo 'copying ssh keys'
		mkdir $vagrant_home/.ssh
		cp -R /vagrant/scripts/ssh/id_rsa{,.pub} $vagrant_home/.ssh/

		# add github's RSA fingerprint to my known hosts
		ssh-keyscan -H github.com >> ~/.ssh/known_hosts

		echo 'cloning dotfiles'
		git clone git@github.com:komidore64/dotfiles.git

		echo 'setting global.gems for ruby 2.2.1'
		mkdir -p $vagrant_home/.rvm/gemsets/ruby/2.2.1
		ln -sf $vagrant_home/dotfiles/rvm/gemsets/ruby/2.1.2/global.gems $vagrant_home/.rvm/gemsets/ruby/2.2.1/

		# still says 'rvm is not a function'
		source $vagrant_home/.rvm/bin/rvm

		echo 'removing ruby 1.9.3'
		rvm --trace remove 1.9.3 --fuzzy

		echo 'installing ruby 2.2.1'
		rvm --trace install 2.2.1

		echo 'set ruby 2.2.1 as default'
		rvm --trace use 2.2.1 --default # oddly, this is the only rvm command that fails

		pushd dotfiles

		echo 'updating git submodule'
		git submodule update --init

		echo 'running dotfiles installer'
		ruby dotfiles_installer.rb --nogui --write-action overwrite

		popd # dotfiles

		popd # $vagrant_home
		echo 'done'
	END_VAGRANT_USER
}

main
