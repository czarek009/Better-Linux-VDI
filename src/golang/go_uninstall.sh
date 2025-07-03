#!/usr/bin/env bash

ENV_PATHS_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/env_variables.sh"
source "${ENV_PATHS_LIB}"
ENV_CONFIGURATOR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../envConfigurator" && pwd)/envConfigurator.sh"
source "${ENV_CONFIGURATOR_PATH}"

remove_dirs() {
    echo "Removing Go directories"
    EnvConfigurator::remove_dir_if_exists "${HOME}/.local/go" "y"
    EnvConfigurator::remove_dir_if_exists "${HOME}/go" "y"
}

# shellcheck disable=SC2016
clean_bashrc() {
	local profile_file="${SHELLRC_PATH}"
	EnvConfigurator::_remove "${profile_file}" \
"
# Go environment setup
unset -f go 2> /dev/null
export GOROOT=\"${HOME}/.local/go\"
export GOPATH=\"${HOME}/go\"
export PATH=\"\$GOROOT/bin:\$GOPATH/bin:\$PATH\""
    echo "Go environment lines removed from ${profile_file}"
}

main() {
	remove_dirs
	clean_bashrc	
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main
fi
