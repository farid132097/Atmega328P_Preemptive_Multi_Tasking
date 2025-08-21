@ECHO OFF

echo Cleaning project...
make clean

echo Building project...
make all

echo Uploading...
make program


PAUSE