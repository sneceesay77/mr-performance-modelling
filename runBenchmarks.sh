#!/bin/bash
echo "Generating Data Using Teragen"
#hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.0.2.jar teragen 5242880 input500
#dataSize=(500 750 1024 1536 2048 2560 3072 4096 4608 5120)
#inumReducer=$((1 + RANDOM % 5))
#echo $numReducer
dataSize=(500 750 1024 1536 2048 2560 3072 4096 4608 5120)
oneMegaByte=1048576
for i in "${dataSize[@]}"
do
   numBytes=$(( $oneMegaByte*$i ))
   numRows=$(( $numBytes/100 ))
   echo Generatig $numRows Rows Using Teragen
   hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.0.2.jar teragen -D dfs.blocksize=134217728 $numRows input$i
   #mapSelectivity=(0.1)
   mapSelectivity=(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1)
   for j in "${mapSelectivity[@]}"
   do
        echo $j
        hadoop jar ClusterBenchmarking-0.0.1-SNAPSHOT.jar\
                bdl.standrews.ac.uk.PlatformDefinedPhaseProfiler\
                -D mapreduce.job.reduces=8\
                -D dfs.blocksize=134217728\
                input$i\
                output$i 128 $j

        #delete output directory
        hadoop fs -rm -r -skipTrash output$i
   done
   hadoop fs -rm -R -skipTrash input$i
done

