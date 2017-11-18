#!/bin/sh

path="$1"
output_file_path="$2"

listing="$(find "$path")"
printf '%s\n' "$listing" | while IFS= read -r ls_line
do
  if   [ -d "$ls_line" ]; then
    echo "$ls_line is a directory, do not write anything in the output file"
  elif [ -f "$ls_line" ]; then
    size="$(ls -l "$ls_line" | awk '{ print $5 }')"
    output_line="$ls_line ---- $size"
    echo "Processing: $ls_line Size: $size Output: $output_line"
    echo "$output_line" >> "$output_file_path"
  else
    echo "Wrong $ls_line"
  fi
done
