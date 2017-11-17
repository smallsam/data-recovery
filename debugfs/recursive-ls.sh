#!/bin/sh

# /150880270/040770/500/100/.//
# /150863873/040777/0/0/..//
# /150888451/040770/500/100/temp//
# /161612929/040770/0/0/Arrow S05E23//
# /150888455/040770/500/100/monitored//
# /161612927/040770/0/0/Sarah Maas - La corona di fuoco//
# /161612931/040770/0/0/William Nicholson - Il Canto Delle Fiamme//
# /161612935/100660/0/0/Zio Paperone 017 (Disney 1991-02) [c2c Frank54 & CapitanUltra].cbr/52088041/
# /161612932/100660/0/0/Dante Alighieri - La divina commedia (Utet, Torino, 2013).pdf/8572224/
# /161612947/100660/0/0/I classici di Walt Disney 043 - Paperino Bang (Mondadori 1980-07) [c2c Fosforo & Aquila & Bibbo64]FIX.cbr/129935407/
# /161612945/100660/0/0/I classici di Walt Disney 044 - Paperin Sansone (Mondadori 1980-08) [c2c Fosforo & Aquila & Bibbo64]FIX.cbr/139668310/
# /161612920/040770/0/0/Dylan Dog i colori della paura 31-40//
# /161612922/100660/0/0/Dylan _ N.362 - Dopo un lungo silenzio by Lollo - Sergio Bonelli.cbr/57431944/
# /161612928/100660/0/0/The.Blacklist.5x02.Greyson.Blaise.ITA.ENG.720p.AMZN.WEBMux.x264-Morpheus.mkv/1902729404/
# /161612904/100660/0/0/La Torre Nera (2017) 1080p AC3 ITA DTS AC3 ENG.mkv/8908036583/
# /161612640/100660/0/0/USS Indianapolis (2016) 1080p DTS AC3 ITA ENG.mkv/11760667669/
# /161612641/100660/0/0/Genius.2016.DTS.ITA.ENG.1080p.BluRay.x264-BLUWORLD.mkv/10270673168/


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

#debugfs -R "ls -l Multimedia" /dev/mapper/cachedev1 | awk '{print $9}' | grep "^[^\.@]" | sort | xargs debugfs -R ls -l Multimedia/{} /dev/mapper/cachedev1
