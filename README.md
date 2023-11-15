# !!Use at your own risk!!
Do NOT use this script if you are unsure if these files have been archived or are in use

## NS_Remove_RTP
Removes RTP files for calls that have been processed to free up space quickly

### Assumptions
- Default LiCf directorys are in use. "/usr/local/NetSapiens/LiCf/recordings/"
- Folders are structured YEAR/MONTH/DAY

### Logic
- This script looks to find .wav files that have corresponding .rtp files. 
- The RTP files should be named the same as the wav file with a -0 or -1 at the end.
#### For Example
---
- 123.wav
- 123-0.rtp
- 123-1.rtp
---
These would match since the wav file has the two matching rtp files. This script will remove only the rtp files. 
**Using the backup option below will move them into a backup folder and compress them as a safer way to get space free.**

## Instructions
- Create remove_rtp.sh file in a directory of your choosing
- chmod +x remove_rtp.sh to make it executable
- Run ./remove_rtp.sh --help to output options below

### Script Options

#### Options:
- --dry-run   Executes the script in dry run mode. No files will be deleted or moved. Output will be files marked for deletion
- --backup    Enables backup of .rtp files. Backed up files will be moved to a 'rtp_backup' folder within the specified directory and zipped.
- --help      Display this help and exit.

#### Example:
- ./remove_rtp.sh --dry-run
- ./remove_rtp.sh --backup
- ./remove_rtp.sh --dry-run --backup

