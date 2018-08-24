// weighted_opt_uni_kmeans.cpp
//
// Joe Song
// Created: May 21, 2016. Extracted from Ckmeans.1d.dp.cpp

#include "Ckmeans.1d.dp.h"

#include <algorithm>
#include <cmath>
#include <iostream>
#include <string>
#include <vector>
#include <ctime>

//#define DEBUG

void fill_weighted_dp_matrix(const std::vector<double> & x,
                             const std::vector<double> & y,
                             std::vector< std::vector< double > > & S,
                             std::vector< std::vector< size_t > > & J)
  /*
  x: One dimension vector to be clustered, must be already sorted
  in asending or desending order.
  y: One dimension vector as weigth of each point, must be nonnegative.
  S: K x N matrix. S[k][i] is the sum of squares of the distance from each x[i]
  to its cluster mean when there are exactly x[i] is the last point in
  cluster k
  J: K x N backtrack matrix

  NOTE: All vector indices in this program start at position 0.
  */
{
  const int K = S.size();
  const int N = S[0].size();

  for(int k = 0; k < K; ++k) {
    S[k][0] = 0.0;
    J[k][0] = 0;
  }

  double mean_x1 = x[0];
  double sum_of_weight_x1 = y[0];

  std::vector<double> mean_xj(x.begin(), x.end());
  std::vector<double> s(N, 0.0); // s: is the sum of squared distances from x_j ,. . ., x_i to their mean

  std::vector<double> sum_weights_j(y.begin(), y.end());


  // Timing parameters
  std::clock_t start = clock();
  clock_t split, lastsplit, estimatesplit;
  std::vector<double>time(N);
  int actualminutes, estimateminutes;
  double actualseconds, estimateseconds;
  double actualtime, estimatetime;
  int progresssize = 40;
  std::cout << "Populating Matrix\t[                                        ]  Elapsed: 0:0, Estimate: calculating...";
  for (int i = 0; i <= 120; i++) {
	  std::cout << "\b";
  }

  start = clock();
  split = start;
  lastsplit = start;

  for(int i = 0; i < N; ++i) {

#ifdef DEBUG
    //std::cout << std::endl << "i=" << i << ":" << std::endl;
#endif

    int kmax = min(i, (i != N-1) ? (K-2) : (K-1));
    // int kmin = (i != N-1) ? 0 : kmax;
    int kmin = 0;

    bool s_is_initialized = false;

    for(int k = kmax; k >= kmin; --k) {

#ifdef DEBUG
     // std::cout << std::endl << "  k=" << k << ":";
#endif

      size_t imin;
      if(k < K - 1) {
        imin = max((size_t)1, (size_t)k);
      } else {
        // No need to compute S[K-1][0] ... S[K-1][N-2]
        imin = N-1;
      }

      if(i < imin) {
        continue;
      }

      if(! s_is_initialized && ((K > 2) || (K==2 && i == N-1))) {
        // Initialize the sum of squared distances
        for(int l = i-1; l >= 0 && l>=J[1][i-1]; --l) {
          double distance = x[l] - mean_xj[l+1];
          // size_t m = i - l;
          sum_weights_j[l] = sum_weights_j[l+1] + y[l];
          s[l] = s[l+1] + y[l] * distance * distance * sum_weights_j[l+1] / sum_weights_j[l];
          mean_xj[l] = (y[l] * x[l] + sum_weights_j[l+1] * mean_xj[l+1]) / sum_weights_j[l];
#ifdef DEBUG
          //std::cout << "s[" << l << "]=" << s[l] << ", ";
#endif
          s_is_initialized = true;
        }
      }

      if(k == 0) {
        double distance = x[i] - mean_x1;
        S[0][i] = S[0][i-1] + y[i] * distance * distance * sum_of_weight_x1
          / (sum_of_weight_x1 + y[i]);
        mean_x1 = (sum_of_weight_x1 * mean_x1 + x[i])
          / (sum_of_weight_x1 + y[i]);
        sum_of_weight_x1 += y[i];

        J[0][i] = 0;

      } else {
        // Initialization of S[k][i]:
        S[k][i] = S[k - 1][i - 1];
        J[k][i] = i;

        int jlow=k; // the lower end for j
        int jhigh=i-1; // the upper end for j

#ifdef DEBUG
        //std::cout << " j-=" << jlow << ", j+=" << jhigh << ":";
#endif
        // jlow = std::max((size_t)jlow, J[k-1][i]);

        if(k < K - 1) {
          jlow = max((size_t)jlow, J[k][i-1]);
        } else {
          jlow = max((size_t)jlow, J[1][i-1]);
        }

        if(k < K - 2) {
          jhigh = min((size_t)jhigh, J[k+1][i]);
        }

        for(int j=jhigh; j>=jlow; --j) {

          // MS May 11, 2016 Added:
          if(s[j] + S[k-1][jlow-1] > S[k][i]) break;

          double SSQ_jlow = s[jlow] + S[k-1][jlow-1];

          if(SSQ_jlow < S[k][i]) {
            S[k][i] = SSQ_jlow;
            J[k][i] = jlow;
          }
          jlow ++;

          double SSQ_j = s[j] + S[k - 1][j - 1];
          if(SSQ_j < S[k][i]) {
            S[k][i] = SSQ_j;
            J[k][i] = j;
          }
        }
      }
#ifdef DEBUG
      //std::cout << std::endl << // " k=" << k << ": " <<
      //  "\t" << S[k][i] << "\t" << J[k][i];
#endif
    }
#ifdef DEBUG
    //std::cout << std::endl;
#endif

	split = clock();
	time[i] = (double)(split - lastsplit) / CLOCKS_PER_SEC;
	//std::cout << time[i] << std::endl;

	// Don't time the timeestimation

	// Give some quick estimates at x=2 and x=20, and then only when the progress bar needs to be updated.
	if (i == 2 || i == 20 || i % (N / progresssize) == 0) {

		// Don't bother calculating estimate if time variation is super small
		//But make sure estimate is calculated at least a few times
		//std::cout << std::endl << "time[" << k << "] = " << time[k] << " time[" << k - 1 << "] = " << time[k - 1] << " abs = " <<abs(time[k] - time[k - 1]) << std::endl;
		//if (k > 1 || (k > 50 && abs(time[k] - time[k-1]) > 0.1)) {
		//estimatetime = getTimeEstimate(time, i, N, x.size());
		//estimatesplit = clock();
		//double estimatetime = (double)(estimatesplit - split) / CLOCKS_PER_SEC;
		//}

		actualminutes = 0;
		actualseconds = 0;
		actualtime = 0;
		for (int j = 0; j < i; j++) {
			actualtime += time[j];
		}
		actualminutes = actualtime / (int)60;
		actualseconds = (int)(actualtime) % 60;

		estimatetime = actualtime;
		for (int j = 0; j < i; j++) {
			estimatetime += time[j];
		}

		estimateminutes = estimatetime / (int)60;
		estimateseconds = (int)(estimatetime) % 60;

		char* actualleadingzero = "";
		char* estimateleadingzero = "";
		if (estimateseconds < 10) estimateleadingzero = "0";
		if (actualseconds < 10) actualleadingzero = "0";

		std::cout << "Populating Matrix\t[";
		for (int j = 0; j < progresssize; j++) {
			if (j >= j * K / progresssize) {
				std::cout << "#";
			}	
			else {
				std::cout << " ";
			}
		}
		std::cout << "] Elapsed: " << actualminutes << ":" << actualleadingzero << actualseconds << ", Estimate: " << estimateminutes << ":" << estimateleadingzero << estimateseconds << "          ";

		//Reset Cursor to start of line
		for (int j = 0; j <= 140; j++) {
			std::cout << "\b";
		}
	}

	//Don't time the timeestimate
	split = clock();
	lastsplit = split;

  }

}


void backtrack_weighted(const std::vector<double> & x, const std::vector<double> & y,
                        const std::vector< std::vector< size_t > > & J,
                        int* cluster, double* centers, double* withinss, int* weights)
{
  const size_t K = J.size();
  const size_t N = J[0].size();
  size_t cluster_right = N-1;
  size_t cluster_left;

  // Backtrack the clusters from the dynamic programming matrix
  for(int k = K-1; k >= 0; --k) {
    cluster_left = J[k][cluster_right];

    for(size_t i = cluster_left; i <= cluster_right; ++i)
      cluster[i] = k;

    double sum = 0.0;
    double weight = 0.0;

    for(size_t i = cluster_left; i <= cluster_right; ++i) {
      sum += x[i] * y[i];
      weight += y[i];
    }

    centers[k] = sum / weight;

    for(size_t i = cluster_left; i <= cluster_right; ++i)
      withinss[k] += y[i] * (x[i] - centers[k]) * (x[i] - centers[k]);

    weights[k] = weight;

    if(k > 0) {
      cluster_right = cluster_left - 1;
    }
  }
}

void backtrack_weighted(
    const std::vector<double> & x, const std::vector<double> & y,
    const std::vector< std::vector< size_t > > & J,
    std::vector<size_t> & counts, std::vector<double> & weights)
{
  const size_t K = J.size();
  const size_t N = J[0].size();
  size_t cluster_right = N-1;
  size_t cluster_left;

  // Backtrack the clusters from the dynamic programming matrix
  for(int k = K-1; k >= 0; --k) {
    cluster_left = J[k][cluster_right];
    counts[k] = cluster_right - cluster_left + 1;

    weights[k] = 0;
    for(size_t i = cluster_left; i <= cluster_right; ++i) {
      weights[k] += y[i];
    }

    if(k > 0) {
      cluster_right = cluster_left - 1;
    }
  }
}
