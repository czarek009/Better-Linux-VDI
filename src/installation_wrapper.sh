#!/usr/bin/env bash

# Usage: install_and_symlink_new_files <install_script>

install_and_symlink_new_files() {
    local install_script
    install_script="$1"

    if [ ! -x "$install_script" ]; then
        echo "Error: $install_script does not exist or is not executable"
        return 1
    fi

    local start_time
    start_time=$(date +"%Y-%m-%d %H:%M:%S")

    echo "Running installation: $install_script"
    if ! bash "$install_script"; then
        echo "Installation failed"
        return 1
    fi


    local now
    now=$(date +"%Y-%m-%d %H:%M:%S")
    local now_epoch
    now_epoch=$(date -d "$now" +%s)
    local start_epoch
    start_epoch=$(date -d "$start_time" +%s)
    local install_time
    install_time=$(( ((now_epoch - start_epoch) / 60) + 1 ))

    local search_dir
    search_dir="/home"
    local dest_base
    dest_base="/local/LinuxRootlessDevKit"
    mapfile -t FILES < <(
      find "$search_dir" \
        -type d \( -path "/home/$USER/.cache" -o -path "/home/$USER/.var" \) -prune -o \
        -type f -newermt "$start_time" -cmin -$install_time -print
    )


    for SRC in "${FILES[@]}"; do
        local rel_path
        rel_path="${SRC#"$search_dir"}"
        local dest
        dest="$dest_base$rel_path"
        local dest_dir
        dest_dir="$(dirname "$dest")"

        mkdir -p "$dest_dir"

        if mv "$SRC" "$dest"; then
            ln -s "$dest" "$SRC"
        else
            echo "Failed to move: $SRC"
        fi
    done
}
