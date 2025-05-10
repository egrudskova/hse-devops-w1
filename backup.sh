#!/bin/bash

DIRECTORY=""
COMPRESSION="gzip"  # Default compression
OUTPUT_FILE=""
ERROR_LOG="error.log"

print_help() {
  echo "Usage: ./backup.sh -d <directory> -c <compression> -o <output_file> [-h|--help]"
  echo ""
  echo "Options:"
  echo "  -d <directory>    The directory to backup (required)."
  echo "  -c <compression>  Compression algorithm (gzip, bzip2, xz, none). Default: gzip"
  echo "  -o <output_file>  The output file name (required, encrypted)."
  echo "  -h, --help        Show this help message and exit."
  echo ""
  echo "Example:"
  echo "  ./backup.sh -d /home/user/data -c bzip2 -o backup.tar.bz2.enc"
}

handle_error() {
  echo "$(date): $1" >> "$ERROR_LOG"
}

backup_directory() {
  local dir="$1"
  local compression="$2"
  local archive="$3.tar"
  local tar_args=""

  case "$compression" in
    "gzip")
      tar_args="-czvf"
      ;;
    "bzip2")
      tar_args="-cjvf"
      ;;
    "xz")
      tar_args="-cJvf"
      ;;
    "none")
      tar_args="-cvf"
      ;;
    *)
      handle_error "Invalid compression algorithm: $compression"
      return 1
      ;;
  esac

  # Create the archive
  tar $tar_args "$archive" "$dir" 2>> "$ERROR_LOG" > /dev/null

  if [ $? -ne 0 ]; then
    handle_error "Tar command failed."
    return 1
  fi

  echo "Successfully created unencrypted tar archive $archive" >&2

  echo "$archive"
}

encrypt_backup() {
    local archive_path="$1"
    local output_file="$2"

    openssl enc -aes-256-cbc -salt -in "$archive_path" -out "$output_file" 2> "$ERROR_LOG" > /dev/null

    if [ $? -ne 0 ]; then
      handle_error "OpenSSL encryption failed."
      return 1
    fi

    rm "$archive_path"
    echo "Successfully encrypted $archive_path and removed"
    return 0

}

while getopts "d:c:o:h" opt; do
  case "$opt" in
    d)
      DIRECTORY="$OPTARG"
      ;;
    c)
      COMPRESSION="$OPTARG"
      ;;
    o)
      OUTPUT_FILE="$OPTARG"
      ;;
    h)
      print_help
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      print_help
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      print_help
      exit 1
      ;;
  esac
done

for arg in "$@"; do
  if [ "$arg" == "--help" ]; then
    print_help
    exit 0
  fi
done


if [ -z "$DIRECTORY" ] || [ -z "$OUTPUT_FILE" ]; then
  echo "Error: Missing required arguments." >&2
  print_help
  exit 1
fi


temp_archive=$(backup_directory "$DIRECTORY" "$COMPRESSION" "temp_archive")
if [ $? -ne 0 ]; then
    echo "Error: Backup process failed"
    exit 1
fi


encrypt_backup "$temp_archive" "$OUTPUT_FILE"
if [ $? -ne 0 ]; then
    echo "Error: Encryption failed"
    exit 1
fi

echo "Backup completed successfully. Encrypted archive: $OUTPUT_FILE"
exit 0
