#!/usr/bin/env bash
# vim: noet

function main () {
	su -l vagrant <<-END_VAGRANT_USER
		echo "moving to \$HOME"
		pushd \$HOME

		echo "copying ssh keys"
		mkdir \$HOME/.ssh
		cp /vagrant/scripts/ssh/id_rsa{,.pub} \$HOME/.ssh/

		echo "copying koji certs and config"
		mkdir \$HOME/.koji
		cp /vagrant/scripts/koji/* \$HOME/.koji/

		# add github's RSA fingerprint to my known hosts
		ssh-keyscan -H github.com >> ~/.ssh/known_hosts

		echo "cloning dotfiles"
		git clone git@github.com:komidore64/dotfiles.git

		echo "setting global.gems for ruby 2.3.0"
		mkdir -p \$HOME/.rvm/gemsets/ruby/2.3.0
		ln -sf \$HOME/dotfiles/rvm/gemsets/ruby/2.1.2/global.gems \$HOME/.rvm/gemsets/ruby/2.3.0/

		if ! which rvm > /dev/null 2>&1; then
			gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
			\\curl -sSL https://get.rvm.io | bash -s stable
		fi

		# still says 'rvm is not a function'
		source \$HOME/.rvm/bin/rvm

		echo "removing ruby 1.9.3"
		rvm remove 1.9.3 --fuzzy

		echo "installing ruby 2.3.0"
		rvm install 2.3.0

		echo "set ruby 2.3.0 as default"
		# turn off shell function check :/
		rvm_is_not_a_shell_function=0 rvm use 2.3.0 --default

		pushd dotfiles

		echo "updating git submodule"
		git submodule update --init

		echo "running dotfiles installer"
		ruby dotfiles_installer.rb --nogui --write-action overwrite

		popd # dotfiles

		popd # \$HOME
		echo 'done'
	END_VAGRANT_USER
}

main
