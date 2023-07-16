import java.io.IOException;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.Reducer;

public class ReduceIt extends Reducer<Text,IntWritable,Text,IntWritable> {
    private IntWritable result = new IntWritable();
    public void reduce(Text key, Iterable<IntWritable> values, Context context
    ) throws IOException, InterruptedException {
        // ------------------------------------------------------------------------
        // --- your code should start here

        int sum = 0; // initialize a variable called "sum" with initial value of zero
        for (IntWritable val : values) { // loop all the values in input
            sum += val.get(); // add each value to the sum
        }
        result.set(sum);  //add sum to the output result
        context.write(key, result);  // write the key-value pair to the output
    }

    // --- your code should end here
    // ------------------------------------------------------------------------
}