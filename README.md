# Spark-Streaming-Examples
Spark Streaming examples using python

## Getting the code

    mkdir SOME_DIRECORY
    cd SOME_DIRECORY
    git clone https://github.com/danielsan/	spark-streaming-examples.git

## Preparing everything
The `setup.sh` script assumes that you already have curl, python, mongodb and Java installed in your system.

Before running the [setup.sh](setup.sh) script I recommend you to see the source code and understand what is it going to do when you run it on your computer. 

**This will take several minutes**

    cd mongodb-analytics-examples && $SHELL ./setup.sh

## Running the analysis with Spark

Assuming your working directory (your current directory in your shell) is the `mongodb-analytics-examples` one

Before running the [spark-ohlcbars-example.submit.sh](spark-ohlcbars-example.submit.sh) script I recommend you to see the source code and understand how to submit a python script to Spark.

    ./spark-ohlcbars-example.submit.sh

Tha script will submit `spark-ohlcbars-example.py` to Spark using `spark-submit`
