using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;

namespace ManagedCKMeans
{
    public class ManagedCKMeans
    {     
        // From c++ Dll (unmanaged)
        [DllImport("UnmanagedCKMeans", CallingConvention = CallingConvention.Cdecl)]
        private static extern long ckmeans(
            double[] values, int numberOfValues, double[] weight,
            int minK, int maxK, int[] cluster,
            double[] centers, double[] withinss, int[] size
        );

        public struct Point
        {
            public double Value;
            public double Weight;
        }

        public struct Cluster {
            public int Size;
            public double MinimumValue;
            public double MaximumValue;
            public double Center;
            public double SumOfSquares;
            public List<Point> Points;
        }
        private List<Point> mPoints;
        private List<Cluster> mClusters;
        private int mMinimumClusters = 0;
        private int mMaximumClusters = 1;


        public List<Cluster> getClusters()
        {
            return mClusters;
        }

        public void AddPoint(double value, double weight = 1)
        {
            if (weight < 0 || weight > 1) {
                throw new Exception("When adding a point, weight must be between 0 and 1. Value: " + value + " weight: " + weight);
            }
            Point point = new Point();
            point.Value = value;
            point.Weight = weight;
            mPoints.Add(point);
        }

        public void AddPoints(double[] values, double[] weights = null)
        {
            for (int index = 0; index < values.Length; index++)
            {
                Point point = new Point();
                point.Value = values[index];
                if (weights == null) {
                    point.Weight = 1.0;
                } else {
                    point.Weight = weights[index];
                }
                mPoints.Add(point);
            }
        }


        //Constructor
        public ManagedCKMeans(int minimumClusters, int maximumClusters)
        {
            mPoints = new List<Point>();
            mMinimumClusters = minimumClusters;
            mMaximumClusters = maximumClusters;
        }


        public List<Cluster> Calculate()
        {
            // Initialise and prepare known data for unmanged DLL call
            double[] value = new double[mPoints.Count];
            double[] weight = new double[mPoints.Count];
            int[] clusterID = new int[mPoints.Count];

            int index = 0;
            foreach (Point point in mPoints) {
                value[index] = point.Value;
                weight[index] = point.Weight;
                index++;
            }

            long optimalClusters = 0;

            // Initialise other unmanaged DLL vars
            double[] center = new double[mMaximumClusters];
            double[] withinss = new double[mMaximumClusters];
            int[] size = new int[mMaximumClusters];

            mClusters = new List<Cluster>();
Console.WriteLine("mtrace 1");
            try
            {
                optimalClusters = ckmeans(value, mPoints.Count, weight, mMinimumClusters, mMaximumClusters, clusterID, center, withinss, size);
            }
            catch (System.Exception e)
            {
                Console.WriteLine("Managed Exception caught");
                Console.WriteLine(e.Message);
                Console.WriteLine(e.Source);
                Console.WriteLine(e.StackTrace);
                Console.WriteLine(e.ToString());
                return mClusters;
            }

Console.WriteLine("mtrace 2");

            Console.WriteLine("value[]: " + value.Length);
            Console.WriteLine("weight[]: " + weight.Length);
            Console.WriteLine("clusterID[]: " + clusterID.Length);
            Console.WriteLine("center[]: " + center.Length);
            Console.WriteLine("withinss[]: " + withinss.Length);
            Console.WriteLine("size[]: " + size.Length);


            // Prepare the clusters
            //for (int clusterIndex = 0; clusterIndex < center.Length && size[clusterIndex] != 0; clusterIndex++)
            
            for (int clusterIndex = 0; clusterIndex < optimalClusters; clusterIndex++) {
                Cluster cluster = new Cluster();
                cluster.Size = size[clusterIndex];
                if (cluster.Size > 0) {
                    cluster.MinimumValue = double.MaxValue;
                    cluster.MaximumValue = double.MinValue;
                } else {
                    cluster.MinimumValue = 0;
                    cluster.MaximumValue = 0;
                }
                cluster.SumOfSquares = withinss[clusterIndex];
                cluster.Center = center[clusterIndex];
                cluster.Points = new List<Point>(cluster.Size);
                mClusters.Add(cluster);
            }
Console.WriteLine("mtrace 3");

            Console.WriteLine("mClusters[]: " + mClusters.Count);
            Console.WriteLine("clusterID[]: " + clusterID.Length);
            Console.WriteLine("mPoints[]: " + mPoints.Count);


            // Add the points to the clusters
            for (int valueIndex = 0; valueIndex < value.Length; valueIndex++) {

                //Console.WriteLine("valueIndex: " + valueIndex);
                //Console.WriteLine("clusterID[valueIndex]: " + clusterID[valueIndex]);
                //Console.WriteLine("mClusters[clusterID[valueIndex]: " + mClusters[clusterID[valueIndex]]);
                //Console.WriteLine("valueIndex: " + valueIndex + ", clusterID[valueIndex]: " + clusterID[valueIndex]);

                //Console.Write(cluster.MaximumValue)

                Cluster cluster = mClusters[clusterID[valueIndex]];
                Point point = mPoints[valueIndex];

                Console.WriteLine("Value: " + point.Value + ", Weight: " + point.Weight);

                // Add the point to the cluster
                cluster.Points.Add(point);

                // Check min and max
                if (point.Value > cluster.MaximumValue) {
                    cluster.MaximumValue = point.Value;
                    mClusters[clusterID[valueIndex]] = cluster;
                }
                if (point.Value < cluster.MinimumValue) {
                    cluster.MinimumValue = point.Value;
                    mClusters[clusterID[valueIndex]] = cluster;
                }
            }
Console.WriteLine("mtrace 4");
            return mClusters;
        }

        
    }
}