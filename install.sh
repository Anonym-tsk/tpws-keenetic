#!/bin/sh

ABSOLUTE_FILENAME=`readlink -f "$0"`
HOME_FOLDER=`dirname "$ABSOLUTE_FILENAME"`

source $HOME_FOLDER/common/install_func.sh

# Start installation
begin_func

# Installing packages
install_packages_func

# Check old configuration
check_old_config_func

# Stop service if exist
stop_func

# Copy files
config_copy_files_func

# Download tpws binary
config_select_arch_func

# Setup local interface
config_local_interface_func

# Starting Services
start_func

exit 0
