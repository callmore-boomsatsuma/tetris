#!/bin/sh
rm tiles/*
magick tetromino-tiles-x24.png -modulate 100,100,132 tiles/tetromino-tiles-x24-yellow.png
magick tetromino-tiles-x24.png -modulate 100,100,160 tiles/tetromino-tiles-x24-green.png
magick tetromino-tiles-x24.png -modulate 100,100,200 tiles/tetromino-tiles-x24-cyan.png
magick tetromino-tiles-x24.png -modulate 100,100,30 tiles/tetromino-tiles-x24-blue.png
magick tetromino-tiles-x24.png -modulate 100,100,50 tiles/tetromino-tiles-x24-purple.png
magick tetromino-tiles-x24.png -modulate 100,100,116 tiles/tetromino-tiles-x24-orange.png
cp tetromino-tiles-x24.png tiles/tetromino-tiles-x24-red.png
