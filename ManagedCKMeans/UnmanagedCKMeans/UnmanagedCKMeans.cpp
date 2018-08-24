// UnmanagedCKMeans.cpp : Defines the exported functions for the DLL application.
//

#define DEBUG

#include "UnmanagedCKMeans.h"
#include "Ckmeans.1d.dp.h"
#include <iostream>
#include <stdio.h>
#include <windows.h>

extern "C" {
	unsigned long ckmeans(
		double *pValues, int numberOfValues, double *pWeights,
		int minK, int maxK, int *pCluster,
		double *pCenter, double *pWithinss, int *pSize
	) {

		/*

		//entry point for Ckmeans.1d.dp.cpp
		void kmeans_1d_dp(const double *x, const size_t N, const double *y,
			size_t Kmin, size_t Kmax,
			int* cluster, double* centers,
			double* withinss, int* size)

		//entry point for Ckmeans.1d.dp_main.cpp
		void Ckmeans_1d_dp(double *x, int* length, double *y, int * ylength,
			int* minK, int *maxK, int* cluster,
			double* centers, double* withinss, int* size)

		//call from Ckmeans_1d_dp to kmeans_1d_dp
		kmeans_1d_dp(x, (size_t)*length, y, (size_t)(*minK), (size_t)(*maxK),
			cluster, centers, withinss, size);

		//Marshalling pointers in c# is a pain.
		//Make the entry point for UnmanagedCKMeans use pre-allocated arrays.
		double x[10] = { 5, 12.3, 78, 54, 22, 23, 21, 65, 4, 4.5 };
		//const double(*x)[10] = &xvalues;
		*/

std::cout << "ckmeans start" << std::endl;
		int *pNumberOfValues = &numberOfValues;
		int *pMinK = &minK;
		int *pMaxK = &maxK;

		try {

			//Check available memory
			checkSystemMemory(2 * 8 * numberOfValues * maxK);


			return kmeans_1d_dp(pValues, (size_t)*pNumberOfValues, pWeights, (size_t)(*pMinK), (size_t)(*pMaxK),
				pCluster, pCenter, pWithinss, pSize);

		} catch (std::exception& e)
		{
			std::cerr << "Unmanaged exception caught: " << e.what() << '\n';
			printTotalSystemMemory(getTotalSystemMemory());
		}
std::cout << "ckmeans end" << std::endl;
return 0;
	}

}