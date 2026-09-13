Here is the README file on how to use the code.

Algorithm Number 1 : Adaptive Iterative Method.

The RSS measurements are calculated for the scenario (averaged RSS) and theta is calculated iteratively over some iterations to get the optimal value. only 4 sensor nodes are used based on maximum rss values and used to solve for optimal theta value.


Algorithm Number 2 : MSE based approach.

Same setup; calculate RSS values for 7x7 sensor grid as described in the paper. We select starting 4 sensors and create combinations of 4 sensors to calculate matrix A which is used to calculate theta value after all the combinations and averaged over N number of experiments to remove randomness caused by log normal shadowing which is modeled as Gaussian random variable for Nsamples. 

These theta values are stored inside the variable theta_samples as we go in increasing the number of sensor nodes which in turn increases number of combinations of sensor nodes to calculate the matrix A. 

Results are plotted for Transmitter Localisation Errors and RSS Error based on the optimal theta estimated at the end of the simulation. 


Algorithm Number 3: LIvE Algorithm.

