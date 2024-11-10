#!/bin/bash

# Get the list of subdirectories under /Volumes
volumes=$(ls /Volumes)

# Prompt the user to select a directory
echo "Please select a directory:"
select selected_volume in $volumes; do
    if [[ -n "$selected_volume" ]]; then
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Check if the selected directory exists
selected_path="/Volumes/$selected_volume"
if [[ ! -d "$selected_path" ]]; then
    echo "The selected directory does not exist: $selected_path"
    exit 1
fi

# Execute the required command
echo "Executing commands..."
sudo chflags -R arch "$selected_path/"
sudo chflags -R noarch "$selected_path/Nintendo/"
sudo mdutil -i off "$selected_path/"
sudo mdutil -E "$selected_path/"
dot_clean -m "$selected_path/"

echo "Operation completed."
