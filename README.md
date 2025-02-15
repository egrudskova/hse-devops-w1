# Backup Script

This script creates an encrypted backup archive of a specified directory, allowing you to choose the compression algorithm and output file name.  All non-error output is suppressed, and errors are logged to `error.log`.


## Usage

./backup.sh -d <directory_to_backup> -c <compression_algorithm> -o <output_file> [-h | --help]


**Arguments:**

*   -d <directory_to_backup>:  The directory you wish to back up. This is a required argument.
*   -c <compression_algorithm>: The compression algorithm to use.  Supported options include none, gzip, bzip2, xz, etc. This is a required argument.
*   -o <output_file>: The name of the output archive file. This will be an encrypted file. This is a required argument.
*   -h | --help: Displays this help message and exits. This argument is optional.

**Examples:**

*   To create an encrypted backup of the /home/user/documents directory using gzip compression and save it as backup.tar.gz.enc:

    ./backup.sh -d /home/user/documents -c gzip -o backup.tar.gz.enc

*   To display the help message:

    ./backup.sh -h
    ./backup.sh --help


## Error Handling

All errors encountered during the backup process are logged to the error.log file.  Check this file for any issues that may have occurred.
