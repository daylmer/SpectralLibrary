using System.Collections.Generic;
using System;
using System;

namespace ManagedCKMeans {
    class Program
    {
        /*
        // From c++ Dll (unmanaged)
        [DllImport("ManagedCKMeans")]
        public static extern double GetThing();
        */

        static void Main(string[] args)
        {

            double[] values = { 5, 12.3, 78, 54, 22, 23, 21, 65, 4, 4.5 };
            double[] weights = { 0.5, 0.5, 0.5, 0.5, 1, 1, 1, 0.5, 0.5, 1 };

            ManagedCKMeans ckmeans = new ManagedCKMeans(1, 10);
            ckmeans.AddPoints(values, weights);

            List<ManagedCKMeans.Cluster> clusters = ckmeans.Calculate();
            
            
            int clusterIndex = 0;
            foreach (ManagedCKMeans.Cluster cluster in clusters)
            {
                Console.WriteLine("Cluster: " + (clusterIndex+1) + " of " + clusters.Count);
                Console.WriteLine("\tSize: " + cluster.Size);
                Console.WriteLine("\tMinimumValue: " + cluster.MinimumValue);
                Console.WriteLine("\tMaximumValue: " + cluster.MaximumValue);
                Console.WriteLine("\tCenter: " + cluster.Center);
                Console.WriteLine("\tSumOfSquares: " + cluster.SumOfSquares);

                int pointIndex = 0;
                foreach (ManagedCKMeans.Point point in cluster.Points)
                {
                    Console.WriteLine("\tPoint: " + pointIndex + " of " + cluster.Points.Count);
                    Console.WriteLine("\t\tValue: " + point.Value);
                    Console.WriteLine("\t\tWeight: " + point.Weight);
                    pointIndex++;
                }

                clusterIndex++;
            }
            Console.ReadKey();
        }
    }
}

