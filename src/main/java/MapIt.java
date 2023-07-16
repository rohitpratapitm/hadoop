import java.io.IOException;
import java.util.StringTokenizer;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.Mapper;

public class MapIt extends Mapper<Object, Text, Text, IntWritable>{
    public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
        // ------------------------------------------------------------------------
        // --- your code should start here

        context.write(new Text("Total"),new IntWritable(1));

        // --- your code should end here
        // ------------------------------------------------------------------------
    }
}