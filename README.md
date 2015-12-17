# Spark-Streaming-Examples
Spark Streaming examples using python

## Getting the code

    mkdir SOME_DIRECORY
    cd SOME_DIRECORY
    git clone https://github.com/danielsan/Spark-Streaming-Examples.git

## Preparing everything
The `setup.sh` script assumes that you already have curl, python, mongodb and Java installed in your system.

Before running the [setup.sh](setup.sh) script I recommend you to see the source code and understand what is it going to do when you run it on your computer. 

**This will take several minutes**

    cd Spark-Streaming-Examples && $SHELL ./setup.sh

## Running the examples with Spark

Assuming your working directory (your current directory in your shell) is the `Spark-Streaming-Examples` one, you can run the command as follow:

    ./pyspark.submit.sh PYTHON_FILE.py

To run the `spark-streaming-reading-files-from-a-folder.py` for exemple you can just do this:

    ./pyspark.submit.sh spark-streaming-reading-files-from-a-folder.py


