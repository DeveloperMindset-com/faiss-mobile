# Example application for iOS using FAISS

Objective-C example that uses `example_c` from the `FAISS` C wrapper.

See original code [here](../../faiss/c_api/example_c.c)

## Development

`ViewController.m` was modified to accomodate iOS file system restrictions:

```Objective-C
NSString *exampleIndexPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/example.index"];

printf("Saving index to disk...\n");
FAISS_TRY(faiss_write_index_fname(index, [exampleIndexPath UTF8String]));
```

## Output

```shell
Generating some data...
Building an index...
is_trained = true
ntotal = 100000
Searching...
I=
    0 (d=0.000)     23 (d=14.844)    362 (d=15.461)    916 (d=15.552)    274 (d=15.662)  
    1 (d=0.000)    439 (d=16.097)    119 (d=16.541)    287 (d=16.663)     62 (d=16.753)  
    2 (d=0.000)    516 (d=15.073)     12 (d=15.188)    309 (d=15.515)    518 (d=15.874)  
    3 (d=0.000)     23 (d=16.026)    149 (d=16.311)    837 (d=16.374)    679 (d=16.875)  
    4 (d=0.000)   1024 (d=14.741)     93 (d=15.248)    832 (d=15.626)    155 (d=15.706)  
I=
  224 (d=13.658)    487 (d=13.949)    447 (d=15.889)    282 (d=15.995)    408 (d=15.998)  
  800 (d=14.963)    229 (d=16.139)    778 (d=16.324)    214 (d=16.574)    817 (d=16.769)  
   73 (d=15.256)     95 (d=15.472)    138 (d=15.707)    145 (d=15.806)    282 (d=15.965)  
  153 (d=14.395)    456 (d=15.214)    219 (d=15.823)     84 (d=15.858)    799 (d=16.339)  
  107 (d=15.417)    277 (d=16.146)    399 (d=16.244)      8 (d=16.271)    750 (d=16.358)  
Searching w/ IDSelectorRange [50,100]
I=
   80 (d=16.921)     89 (d=17.617)     63 (d=17.737)     66 (d=17.778)     69 (d=17.822)  
   62 (d=17.404)     74 (d=18.343)     87 (d=18.347)     79 (d=18.506)     67 (d=18.942)  
   73 (d=15.256)     95 (d=15.472)     62 (d=16.410)     50 (d=18.087)     78 (d=18.177)  
   84 (d=15.858)     79 (d=17.148)     73 (d=18.072)     59 (d=18.281)     80 (d=19.062)  
   97 (d=17.417)     71 (d=17.774)     77 (d=18.068)     94 (d=18.193)     76 (d=18.304)  
Searching w/ IDSelectorRange [20,40] OR [45,60] 
I=
   36 (d=17.505)     59 (d=18.177)     25 (d=18.351)     30 (d=18.359)     48 (d=18.622)  
   38 (d=17.972)     28 (d=18.558)     21 (d=18.685)     31 (d=19.089)     32 (d=19.220)  
   34 (d=17.832)     23 (d=18.082)     50 (d=18.087)     52 (d=18.312)     38 (d=18.416)  
   45 (d=17.935)     59 (d=18.281)     23 (d=18.614)     35 (d=18.647)     52 (d=19.279)  
   48 (d=16.955)     34 (d=16.993)     30 (d=17.720)     22 (d=18.158)     36 (d=18.229)  
Searching w/ IDSelectorRange [20,40] AND [15,35] = [20,35]
I=
   25 (d=18.351)     30 (d=18.359)     23 (d=18.912)     22 (d=19.618)     27 (d=19.914)  
   28 (d=18.558)     21 (d=18.685)     31 (d=19.089)     32 (d=19.220)     20 (d=19.610)  
   34 (d=17.832)     23 (d=18.082)     33 (d=18.669)     24 (d=19.275)     21 (d=19.411)  
   23 (d=18.614)     34 (d=19.338)     28 (d=20.344)     22 (d=20.422)     29 (d=20.669)  
   34 (d=16.993)     30 (d=17.720)     22 (d=18.158)     27 (d=18.567)     33 (d=18.916)  
Saving index to disk...
Freeing index...
Done.
Program ended with exit code: 0
```

## Screenshots

![](/docs//assets/001-building-faiss-index-on-ios.png)
![](/docs//assets/002-done-building-faiss-index-on-ios.png)