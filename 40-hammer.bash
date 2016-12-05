#!/usr/bin/env bash
# vim: noet

function main() {
	su -l vagrant <<-END_VAGRANT_USER
		pushd \$HOME

		git clone https://github.com/theforeman/hammer-cli.git -o upstream
		git clone https://github.com/theforeman/hammer-cli-foreman.git -o upstream
		git clone http://github.com/katello/hammer-cli-katello.git -o upstream

		# hammer configs
		mkdir -p \$HOME/.hammer/cli.modules.d
		cat > \$HOME/.hammer/cli_config.yml <<-END_CLI_CONFIG
			# User interface related settings
			:ui:
			  # Enable interactive queries?
			  :interactive: true
			  # Number of records listed per page
			  :per_page: 9999
			  # Location of shell history file
			  :history_file: '~/.hammer/history'

			# Enable/disable color output of logger in Clamp commands
			:watch_plain: false

			# Forece relaod of Apipie cache with every Hammer invocation
			:reload_cache: true

			# Directory where the logs are stored. The default is /var/log/hammer/ and the log file is named hammer.log
			:log_dir: '~/.hammer/log'

			# Logging level. One of debug, info, warning, error, fatal
			:log_level: 'debug'

			#:log_owner: 'foreman'
			#:log_group: 'foreman'

			# Maximum log size in bytes. Log rotates when the value gets exceeded
			#:log_size: 5 #in MB

			# Mark translated strings with X characters (for developers)
			#:mark_translated: false
		END_CLI_CONFIG

		cat > \$HOME/.hammer/cli.modules.d/foreman.yml <<-END_FOREMAN_YML
			:foreman:
			  :enable_module: true
			  :host: 'http://localhost:3000/'
			  :username: 'admin'
			  :password: 'changeme'
		END_FOREMAN_YML

		cat > \$HOME/.hammer/cli.modules.d/katello.yml <<-END_KATELLO_YML
			:katello:
			  :enable_module: true
		END_KATELLO_YML

		pushd hammer-cli
		git remote add fork git@github.com:komidore64/hammer-cli.git
		git fetch --all --prune
		popd # hammer-cli

		pushd hammer-cli-foreman
		git remote add fork git@github.com:komidore64/hammer-cli-foreman.git
		git fetch --all --prune
		popd # hammer-cli-foreman

		pushd hammer-cli-katello
		git remote add fork git@github.com:komidore64/hammer-cli-katello.git
		git fetch --all --prune
		cat > Gemfile.local <<-END_GEMFILE_LOCAL
			gem 'hammer_cli', :path => '../hammer-cli'
			gem 'hammer_cli_foreman', :path => '../hammer-cli-foreman'
		END_GEMFILE_LOCAL
		echo "2.3.0" > .ruby-version
		echo "hammer" > .ruby-gemset
		rvm gemset create hammer
		rvm_is_not_a_shell_function=0 rvm use 2.3.0@hammer
		bundle install
		popd # hammer-cli-katello

		popd # \$HOME
	END_VAGRANT_USER
}

main
