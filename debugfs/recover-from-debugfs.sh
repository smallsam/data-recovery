#!/bin/sh

debugfs_recover_file () {
  source="$1"
  destination="$2"
  device="$3"
  echo "$(debugfs -R "dump \"$source\" \"$destination\"" "$device")"
}

recover () (
  input_file_path="$1"
  device="$2"
  output_file_path="$3"

  lines_count="$(wc -l "$input_file_path" | awk '{ print $1; }')"
  echo "$lines_count files to recover from $device"

  while read ls_line; do
    echo "Processing $processed_count/$lines_count: $ls_line"
    ls_line="$(echo "$ls_line" | sed -e "s/ /\ /g")"
    echo "Escaped $ls_line"
    destination_path="/share/WD3TB2/$ls_line"
    echo "Destination path: $destination_path"
    dirname="$(dirname "$destination_path")"
    echo "Ensure path to destination exists. Dirname: $dirname"
    mkdir -p "$dirname"
    debugfs_recover_file "$ls_line" "$destination_path" "$device"
    ls_line="$(echo "$ls_line" | sed -e "s/\ / /g")"
    echo "Removed escapes from $ls_line"
    echo "Recovered $processed_count/$lines_count $ls_line" > "$output_file_path"
    processed_count=$(expr $processed_count + 1)
  done < "$input_file_path"
)

input_path="$1"
device="$2"
log_file_path="$3"
processed_count=1

echo "Recovering files listed in $input_path from $device device. Saving log in: $log_file_path"
recover "$input_path" "$device" "$log_file_path"
