"""
To run
  ./pyspark.submit.sh spark-streaming-foreachRDD-and-foreachPartition.py
"""

from pyspark import SparkContext, SparkConf
from pyspark.streaming import StreamingContext

from quiet_logs import quiet_logs

if __name__ == "__main__":
    conf = SparkConf().setAppName("Reading files from a directory")
    sc   = SparkContext(conf=conf)
    ssc  = StreamingContext(sc, 2)

    quiet_logs(sc)

    lines = ssc.textFileStream('./streamingData')

    # Split each line into words
    words = lines.flatMap(lambda line: line.split(" "))

    # Count each word in each batch
    pairs = words.map(lambda word: (word, 1))

    wordCounts = pairs.reduceByKey(lambda x, y: x + y)

    # Print the first ten elements of each RDD generated in this DStream to the console
    wordCounts.pprint()

    ssc.start()             # Start the computation
    ssc.awaitTermination()  # Wait for the computation to terminate