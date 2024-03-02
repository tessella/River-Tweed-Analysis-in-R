The main script for the project consists of:
1. Generate the basin datatype using elevation data. Aggregate the data to perform calculations on it.
2. Associate initial hydrology features to river datatype. Once created, iterate through the discharge csvs found in
   [Data](https://github.com/tessella/River-Tweed-Analysis-in-R/tree/71faca8ba656599e6d22631e4447d86db896953d/Data)
   to generate each river datatype related to the predicted yearly discharges.
4. Having created all river datatypes for all scenarios, the script proceeds to iterate through them and extract the
   discharge from the [circled node](https://github.com/tessella/River-Tweed-Analysis-in-R/blob/71faca8ba656599e6d22631e4447d86db896953d/Plots/tweed_agg.png).
5. Finally, the data is plotted.
   
