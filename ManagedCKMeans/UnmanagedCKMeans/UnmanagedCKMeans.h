// UnmanagedCKMeans.h

// http://ericeastwood.com/blog/17/unity-and-dlls-c-managed-and-c-unmanaged

#ifdef UNMANAGEDCKMEANS_EXPORT
#define UNMANAGEDCKMEANS_API __declspec(dllexport) 
#else
#define UNMANAGEDCKMEANS_API __declspec(dllimport) 
#endif

#define DEBUG

extern "C" {
	UNMANAGEDCKMEANS_API unsigned long ckmeans(
		double *pValues, int NumberOfValues, double *pWeights,
		int minK, int maxK, int *pCluster,
		double *pCenter, double *pWithinss, int *pSize
	);
}