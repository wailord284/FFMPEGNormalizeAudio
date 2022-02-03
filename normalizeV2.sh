#!/bin/bash
#increase or decrease volume in files
#https://www.maketecheasier.com/normalize-music-files-with-ffmpeg/

echo -e "Enter full path of folder with music"
read -e -r folder
folder=${folder:-/home/alex/Music}
echo -e "\nHow much do you want to change the volume by?\nFor example, enter 1.5 to increase, 0.5 to decrease or loudnorm to normalize" 
read -e -r volume
volume=${volume:-loudnorm}
echo "volume is set to $volume"
echo "What is the audio extension of your files? example: .m4a"
read -e -r extension
sleep 2s

#create output folder path
outputFolder="$folder"/normalized
#count how many characters are in the folders name
folderCharacters=$(echo -n "$folder" | wc -c )
#https://stackoverflow.com/questions/6348902/how-can-i-add-numbers-in-a-bash-script
#add 2 to the total folder count to get complete length
folderLength=$((folderCharacters + 2))
#create output folder normalized
mkdir "$folder"/normalized
#create array audioFiles
declare -a audioFiles

#https://stackoverflow.com/questions/11426529/reading-output-of-a-command-into-an-array-in-bash
#find all m4a files in folder then add them to audioFiles array. mapfile adds command output to array
mapfile -t audioFiles < <(find "$folder"/*."$extension")
#get each file with full path from audioFiles

for file in "${audioFiles[@]}" ; do
	#remove the folder path from the song name to add to output/songName
	songName=$(echo "$file" | cut -c$folderLength-)
	echo "$songName" 
	#https://stackoverflow.com/questions/13592709/retrieve-album-art-using-ffmpeg
	#save album art as the audio conversion removes it
	ffmpeg -i "$file" -an -vcodec copy "$outputFolder"/cover.jpg
	if [ "$volume" = loudnorm ]; then
		#normalize volume using loudnorm, -map 0:0 is audio, 0:1 is album art/metadata
		ffmpeg -i "$file" -map 0:0 -filter:a "$volume" "$outputFolder"/"$songName"
	else
		#increase volume by $volume times, -map 0:0 is audio, 0:1 is album art/metadata
		ffmpeg -i "$file" -map 0:0 -filter:a "volume=$volume" "$outputFolder"/"$songName"
	fi
	#https://stackoverflow.com/questions/17798709/ffmpeg-how-to-embed-cover-art-image-to-m4a
	#re-add the album art to the new song
	mp4art --add "$outputFolder"/cover.jpg "$outputFolder"/"$songName"
	rm "$outputFolder"/cover.jpg
done
