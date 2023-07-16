import java.io.IOException;
import java.util.StringTokenizer;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class MapReduceIt {
    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
// ----------------------------------------------------------------------
// start of the area that may need change

        Job job = Job.getInstance(conf, "test");  // name your job
        job.setJarByClass(MapReduceIt.class);  // define the class with main method
        job.setMapperClass(MapIt.class);  // define mapper class
        job.setCombinerClass(ReduceIt.class);  // define conbiner class
        job.setReducerClass(ReduceIt.class); // define reducer class
        job.setOutputKeyClass(Text.class);  // define type of the key
        job.setOutputValueClass(IntWritable.class);  // define type of the value
        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

// end of the area that may need change
// ----------------------------------------------------------------------
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}