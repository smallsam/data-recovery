#!/bin/sh

debugfs_ls () {
  path="$1"
  device="$2"
  echo "$(debugfs -R "ls -l -p \"$path\"" "$device")"
}

get_name () {
  input=$1
  echo "$input" | awk -F "/" '{print $6}'
}

get_size () {
  input=$1
  echo "$input" | awk -F "/" '{print $7}'
}

is_directory () {
  input="$1"
  size="$(get_size "$input")"
  if [ ! "$size" ]; then
    return 0
  else
    return 1
  fi
}

recursive_ls () (
  path="$1"
  device="$2"
  output_file_path="$3"

  echo "Recursive ls of $path in $device device. Saving output in $output_file_path"

  listing="$(debugfs_ls "$path" "$device")"
  printf '%s\n' "$listing" | while IFS= read -r ls_line
  do
    echo "Processing: $ls_line"
    name="$(get_name "$ls_line")"
    echo "Name: $name"
    complete_path="$path/$name"
    echo "Complete path: $complete_path"
    if ! is_directory "$ls_line" ; then
      size="$(get_size "$ls_line")"
      echo "$complete_path is a file of size $size. Adding it to the file list"
      complete_path="$(echo "$complete_path" | sed -e "s/\ / /g")"
      echo "Removed escapes from $complete_path"
      echo "$complete_path ---- $size" >> "$output_file_path"
    else
      if [ "$name" = "." -o "$name" = ".." -o "$name" = ".@__thumb" ]; then
        echo "Skipping . .. .@__thumb directories"
      else
        echo "$complete_path is a directory. Let's dig deeper"
        complete_path="$(echo "$complete_path" | sed -e "s/ /\ /g")"
        echo "Escaped $complete_path"
        recursive_ls "$complete_path" "$device" "$output_file_path"
      fi
    fi
  done
)

initial_path="$1"
device="$2"
output_file_path="$3"

echo "Starting from $initial_path in $device device. Saving output: $output_file_path"
recursive_ls "$initial_path" "$device" "$output_file_path"
