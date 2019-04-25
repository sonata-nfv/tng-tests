-- example reporting script which demonstrates a custom
-- done() function that prints results as JSON

done = function(summary, latency, requests)
   io.write("\nJSON Output\n")
   io.write("-----------\n\n")
   io.write("{\n")
   io.write(string.format("\t\"requests\": %d,\n", summary.requests))
   io.write(string.format("\t\"duration_in_microseconds\": %0.2f,\n", summary.duration))
   io.write(string.format("\t\"bytes\": %d,\n", summary.bytes))
   io.write(string.format("\t\"requests_per_sec\": %0.2f,\n", (summary.requests/summary.duration)*1e6))
   io.write(string.format("\t\"bytes_transfer_per_sec\": %0.2f,\n", (summary.bytes/summary.duration)*1e6))

   io.write("\t\"latency_distribution\": [\n")
   for _, p in pairs({ 50, 75, 90, 99, 99.9, 99.99, 99.999, 100 }) do
      io.write("\t\t{\n")
      n = latency:percentile(p)
      io.write(string.format("\t\t\t\"percentile\": %g,\n\t\t\t\"latency_in_microseconds\": %d\n", p, n))
      if p == 100 then 
          io.write("\t\t}\n")
      else 
          io.write("\t\t},\n")
      end
   end
   io.write("\t],\n")

   io.write("\t\"graphs\": [\n")
   io.write("\t\t{\n")
   io.write("\t\t\t\"title\": \"Latency Distribution\",\n")
   io.write("\t\t\t\"x-axis-title\": \"Percentile\",\n")
   io.write("\t\t\t\"x-axis-unit\": \"Percentage\",\n")
   io.write("\t\t\t\"y-axix-title\": \"Latency microseconds\",\n")
   io.write("\t\t\t\"y-axis-unit\": \"Microseconds\",\n")
   io.write("\t\t\t\"type\": \"bar\",\n")
   io.write("\t\t\t\"series\": {\n")
   io.write(string.format("\t\t\t\t\t\"s1\": \"latency\"\n"))
   io.write("\t\t\t\t},\n")
   io.write("\t\t\t\"data\": {\n")
   io.write("\t\t\t\t\t \"s1x\": [50, 75, 90, 99, 99.9, 99.99, 99.999, 100],\n")
   io.write("\t\t\t\t\t \"s1y\": [")
   for _, p in pairs({ 50, 75, 90, 99, 99.9, 99.99, 99.999, 100 }) do
      n = latency:percentile(p)
      io.write(string.format("%g ", n))
      if p == 100 then 
          io.write("]\n")
      else 
          io.write(",")
      end
   end
   io.write("\t\t\t\t}\n")
   io.write("\t\t}\n")
   io.write("\t]\n}\n")
end
