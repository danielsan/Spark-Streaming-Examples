"""
 Counts words in UTF8 encoded, '\n' delimited text received from the network every second.

 To run this on your local machine, you need to first run a Netcat server
    `$ nc -lk 9999`

 and then run the example
    `$ ./pyspark.submit.sh spark-streaming-listening-to-a-tcp-port.py
"""

from pyspark import SparkContext, SparkConf
from pyspark.streaming import StreamingContext

from quiet_logs import quiet_logs

if __name__ == "__main__":
    conf = SparkConf().setAppName("Listening to a tcp port")
    sc   = SparkContext(conf=conf)
    ssc  = StreamingContext(sc, 1)

    quiet_logs(sc)

    lines = ssc.socketTextStream("localhost", 9998)

    # Split each line into words
    words = lines.flatMap(lambda line: line.split(" "))

    # Count each word in each batch
    pairs = words.map(lambda word: (word, 1))


    wordCounts = pairs.reduceByKey(lambda x, y: x + y)

    # Print the first ten elements of each RDD generated in this DStream to the console
    wordCounts.pprint()


    ssc.start()             # Start the computation
    ssc.awaitTermination()  # Wait for the computation to terminate