#!/usr/bin/env bash
# This script assumes that ImageMagick is installed and the convert command is accessible via the $PATH variable

# Ensure that three arguments have been passed in.
if [ ! "$#" -eq 3 ]
then
	echo -e "This script requires three arguments, filename, tile size and levels of detail.\\ne.g. tile_slicer.sh test.png 256 3"
	exit 1
fi

# Assign arguments to named variables so they are easier to follow throughout the script.
filename=$1
tileSize=$2
levelsOfDetail=$3

# Ensure that the filename has no whitespace.
case $filename in
	*\ * )
		echo "Filename may not contain any whitespace."
		exit 1
		;;
esac

# Ensure that the filename points to a valid file.
if [ ! -f $filename ]
then
	echo "Filename must point to a valid file."
	exit 1
fi

# Ensure that the tile size is a positive integer.
if  ! [[ $tileSize =~ ^[0-9]+$ ]]
then
	echo $"Tile size must be a positive integer."
	exit 1
fi

# Ensure that the levels of detail is a positive integer.
if  ! [[ $levelsOfDetail =~ ^[0-9]+$ ]]
then
	echo $"Levels of detail must be a positive integer."
	exit 1
fi

# This function takes in the level of detail and creates all the nescessary tiles for it
function createTiles()
{
	zoomLevel=$((2**(${1}-1)))
	
	# Because bash does not support floating point division we need to use awk to calculate the scale of the image.
	scale=$(awk 'BEGIN { print (100/'$zoomLevel') }')

	convert $filename -scale ${scale}% -crop ${tileSize}x${tileSize} -strip -set filename:tile "%[fx:page.x/${tileSize}]_%[fx:page.y/${tileSize}]" +repage +adjoin "${filename%.*}_${zoomLevel}_%[filename:tile].${filename#*.}"
}

for levelOfDetail in $(seq $levelsOfDetail)
do
	createTiles $levelOfDetail
done
