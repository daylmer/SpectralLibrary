// select_levels.cpp
//
// Joe Song
// Created: May 15, 2016. Extracted from Ckmeans.1d.dp.cpp
// Modified:
//   May 22, 2016. Incorporated a numerically stable method for computing
//   variance when selecting the number of clusters.

#include <algorithm>
#include <cmath>
#include <iostream>
#include <string>
#include <vector>
#include <numeric>
#include <ctime>

#include "Ckmeans.1d.dp.h"

#ifndef M_PI
const double M_PI = 3.14159265359;
#endif

void shifted_data_variance(const std::vector<double> & x,
                           const size_t left,
                           const size_t right,
                           double & mean, double & variance)
{
  double sum = 0.0;
  double sumsq = 0.0;

  mean = 0.0;
  variance = 0.0;

  size_t n = right - left + 1;

  if(right >= left) {

    double median = x[(left + right) / 2];

    for (size_t i = left; i <= right; ++i) {
      sum += x[i] - median;
      sumsq += (x[i] - median) * (x[i] - median);
    }
    mean = sum / n + median;

    if (n > 1) {
      variance = (sumsq - sum * sum / n) / (n - 1);
    }
  }

}

// Choose an optimal number of levels between Kmin and Kmax
size_t select_levels(const std::vector<double> & x,
                     const std::vector< std::vector< size_t > > & J,
                     size_t Kmin, size_t Kmax)
{
  if (Kmin == Kmax) {
    return Kmin;
  }

  const std::string method = "normal"; // "uniform" or "normal"

  size_t Kopt = Kmin;

  const size_t base = 0;  // The position of first element in x: 1 or 0.
  const size_t N = x.size() - base;

  double maxBIC;

  // progress bar
  // Timing parameters
  std::clock_t start = clock();
  clock_t split, lastsplit, estimatesplit;
  std::vector<double>time(Kmax - Kmin + 1);
  int actualminutes, estimateminutes;
  double actualseconds, estimateseconds;
  double actualtime, estimatetime;

  int progresssize = 40;
  std::cout << "Optimising Clusters\t[                                        ]";
  for (int i = 0; i <= 120; i++) {
	  std::cout << "\b";
  }
  start = clock();
  split = start;
  lastsplit = start;


  for(size_t K = Kmin; K <= Kmax; ++K) {

    std::vector< std::vector< size_t > > JK(J.begin(), J.begin()+K+base);
    std::vector<size_t> size(K+base);

    // Backtrack the matrix to determine boundaries between the bins.
    backtrack(x, JK, size);

    size_t indexLeft = base;
    size_t indexRight;

    double loglikelihood = 0;
    double binLeft, binRight;

    for (size_t k = 0; k < K; ++k) { // Compute the likelihood

      size_t numPointsInBin = size[k+base];

      indexRight = indexLeft + numPointsInBin - 1;

      /* Use mid point inbetween two clusters as boundary
       binLeft = ( indexLeft == base ) ?
       x[base] : (x[indexLeft-1] + x[indexLeft]) / 2;

       binRight = ( indexRight < N-1+base ) ?
       (x[indexRight] + x[indexRight+1]) / 2 : x[N-1+base];
       */

      if(x[indexLeft] < x[indexRight]) {
        binLeft = x[indexLeft];
        binRight = x[indexRight];
      } else if(x[indexLeft] == x[indexRight]) {
        binLeft = ( indexLeft == base ) ?
        x[base] : (x[indexLeft-1] + x[indexLeft]) / 2;
        binRight = ( indexRight < N-1+base ) ?
        (x[indexRight] + x[indexRight+1]) / 2 : x[N-1+base];
      } else {
        throw "ERROR: binLeft > binRight";
        // cout << "ERROR: binLeft > binRight" << endl;
      }

      double binWidth = binRight - binLeft;

      if(method == "uniform") {

        loglikelihood += numPointsInBin * std::log(numPointsInBin / binWidth / N);

      } else if(method == "normal") {

        double mean, variance;

        shifted_data_variance(x, indexLeft, indexRight, mean, variance);

        if (variance > 0) {
          for (size_t i = indexLeft; i <= indexRight; ++i) {
            loglikelihood += - (x[i] - mean) * (x[i] - mean)
            / (2.0 * variance);
          }
          loglikelihood += numPointsInBin
            * (std::log(numPointsInBin / (double) N)
                 - 0.5 * std::log ( 2 * M_PI * variance));
        } else {
          loglikelihood += numPointsInBin * std::log(1.0 / binWidth / N);
        }

      } else {
        throw "ERROR: Wrong likelihood method!";
        // cout << "ERROR: Wrong likelihood method" << endl;
      }

      indexLeft = indexRight + 1;
    }

    double BIC = 0.0;

    // Compute the Bayesian information criterion
    if (method == "uniform") {
      BIC = 2 * loglikelihood - (3 * K - 1) * std::log((double)N);  // K-1
    } else if(method == "normal") {
      BIC = 2 * loglikelihood - (3 * K - 1) * std::log((double)N);  //(K*3-1)
    }

    // cout << ", Loglh=" << loglikelihood << ", BIC=" << BIC << endl;

    if (K == Kmin) {
      maxBIC = BIC;
      Kopt = Kmin;
    } else {
      if (BIC > maxBIC) {
        maxBIC = BIC;
        Kopt = K;
      }
    }


	int ki = K - Kmin;
	int kn = Kmax - Kmin;

	split = clock();
	time[ki] = (double)(split - lastsplit) / CLOCKS_PER_SEC;

	//std::cout << "time[" << ki << "] = " << time[ki];

	// Don't time the timeestimation
	// Give some quick estimates at x=2 and x=20, and then only when the progress bar needs to be updated.
	if (ki == 2 || ki == 20 || ki % (kn / progresssize) == 0) {

		actualminutes = 0;
		actualseconds = 0;
		actualtime = 0;
		for (int i = 0; i < ki; i++) {
			actualtime += time[i];
		}
		actualminutes = actualtime / (int)60;
		actualseconds = (int)(actualtime) % 60;
		estimatetime = actualtime;
		for (int i = ki; i < kn; i++) {
			estimatetime += time[ki];
		}

		estimateminutes = estimatetime / (int)60;
		estimateseconds = (int)(estimatetime) % 60;

		char* actualleadingzero = "";
		char* estimateleadingzero = "";
		if (estimateseconds < 10) estimateleadingzero = "0";
		if (actualseconds < 10) actualleadingzero = "0";

		std::cout << "Optimising Clusters\t[";
		for (int i = 0; i < progresssize; i++) {
			if (ki >= i * kn / progresssize) {
				std::cout << "#";
			}
			else {
				std::cout << " ";
			}
		}
		std::cout << "] Elapsed: " << actualminutes << ":" << actualleadingzero << actualseconds << ", Estimate: " << estimateminutes << ":" << estimateleadingzero << estimateseconds << "          ";

		//Reset Cursor to start of line
		for (int i = 0; i <= 120; i++) {
			std::cout << "\b";
		}
	}

	//Don't time the timeestimate
	split = clock();
	lastsplit = split;
  }
  std::cout << std::endl;
  return Kopt;
}
