#!/bin/bash

# Function to display help information
display_help() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Options:"
  echo "  --dry-run   Executes the script in dry run mode. No files will be deleted or moved. Output will be files marked for deletion"
  echo "  --backup    Enables backup of .rtp files. Backed up files will be moved to a 'rtp_backup' folder within the specified directory and zipped."
  echo "  --help      Display this help and exit."
  echo
  echo "Example:"
  echo "  $0 --dry-run"
  echo "  $0 --backup"
  echo "  $0 --dry-run --backup"
}

# Check for help, dry run, and backup options
for arg in "$@"; do
  case $arg in
    --help)
      display_help
      exit 0
      ;;
    --dry-run)
      dry_run_option="yes"
      shift # Shift the positional parameters to the left
      ;;
    --backup)
      backup_option="yes"
      shift
      ;;
    *)
      # Unknown option
      echo "Unknown option: $arg"
      display_help
      exit 1
      ;;
  esac
done

# Function to remove or backup .rtp files for a specific date folder
remove_rtp_files() {
  local date_folder="$1"
  local dry_run="$2"
  local backup="$3"
  local backup_dir="/usr/local/NetSapiens/LiCf/recordings/$date_folder/rtp_backup"

  # Create backup directory if backup option is enabled
  if [[ "$backup" == "yes" ]]; then
    mkdir -p "$backup_dir"
  fi

  # Check if the specified date folder exists
  if [ -d "/usr/local/NetSapiens/LiCf/recordings/$date_folder" ]; then
    # Change to the specified date folder
    cd "/usr/local/NetSapiens/LiCf/recordings/$date_folder"

    # Loop through all .wav files
    for wav_file in *.wav; do
      # Corresponding .rtp files
      rtp_0_file="${wav_file%.wav}-0.rtp"
      rtp_1_file="${wav_file%.wav}-1.rtp"

      # Check if .rtp files exist
      if [ -e "$rtp_0_file" ] || [ -e "$rtp_1_file" ]; then
        if [[ "$dry_run" == "yes" ]]; then
          echo "Dry run: Would process $rtp_0_file and $rtp_1_file"
        else
          if [[ "$backup" == "yes" ]]; then
            mv "$rtp_0_file" "$backup_dir/"
            mv "$rtp_1_file" "$backup_dir/"
            echo "Moved $rtp_0_file and $rtp_1_file to $backup_dir"
          else
            rm "$rtp_0_file"
            rm "$rtp_1_file"
            echo "Removed $rtp_0_file and $rtp_1_file"
          fi
        fi
      fi
    done

    # Zip the backup directory if backup option is enabled
    if [[ "$backup" == "yes" ]]; then
      tar -czf "${backup_dir}.tar.gz" -C "$backup_dir" .
      echo "Compressed backup directory into ${backup_dir}.tar.gz"
      rm -rf "$backup_dir"  # Optionally remove the uncompressed backup directory
    fi

    echo "Processed .rtp files in folder '/usr/local/NetSapiens/LiCf/recordings/$date_folder'."
  else
    echo "Date folder '/usr/local/NetSapiens/LiCf/recordings/$date_folder' not found."
  fi
}

# Prompt for the date or date range
read -p "Enter the date or date range (e.g., 2023/11/15 or 2023/11/15-2023/11/17): " input

# Check if the input contains a hyphen to indicate a date range
if [[ "$input" == *-* ]]; then
  echo "Date Range Specified"
  # Date range specified, use the input directly as the range
  date_range="$input"
  IFS='-' read -r -a dates <<< "$date_range"

  # Iterate through the date range and call remove_rtp_files for each date
  for current_date in "${dates[@]}"; do
    echo "Working on $current_date"
    remove_rtp_files "$current_date" "$dry_run_option" "$backup_option"
  done
else
  echo "Single Date Specified"
  # Single date specified, call remove_rtp_files for that date
  remove_rtp_files "$input" "$dry_run_option" "$backup_option"
fi