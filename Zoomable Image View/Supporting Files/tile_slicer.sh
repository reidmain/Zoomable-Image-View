#!/usr/bin/env bash
# This script assumes that ImageMagick is installed and the convert command is accessible via the $PATH variable

# Check that three arguments have been passed in.
if [ ! "$#" -eq 3 ]
then
	echo -e "This script requires three arguments.\\ne.g. tile_slicer.sh test.png 256 3"
	exit 1
fi

file=$1
tileSize=$2
levelsOfDetail=$3

# Check that the file exists.
if [ ! -f $file ]
then
	echo "First argument must be a file with no whitespace in the name."
	exit 1
fi

# Check that the tile size is an integer.
if  ! [[ $tileSize =~ ^[0-9]+$ ]]
then
	echo $"Second argument must be a positive integer."
	exit 1
fi

# Check that the levels of detail is an integer.
if  ! [[ $levelsOfDetail =~ ^[0-9]+$ ]]
then
	echo $"Third argument must be a positive integer."
	exit 1
fi

# This function takes in the level of detail and creates all the nescessary tiles for it
function createTiles()
{
	zoomLevel=$((2**(${1}-1)))
	
	# Because bash does not support floating point division we need to use awk to calculate the scale of the image.
	scale=$(awk 'BEGIN { print (100/'$zoomLevel') }')

	convert $file -scale ${scale}% -crop ${tileSize}x${tileSize} -strip -set filename:tile "%[fx:page.x/${tileSize}]_%[fx:page.y/${tileSize}]" +repage +adjoin "${file%.*}_${zoomLevel}_%[filename:tile].${file#*.}"
}

for levelOfDetail in $(seq $levelsOfDetail)
do
	createTiles $levelOfDetail
done
