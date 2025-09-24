namespace Fake
{
    /// <summary>
    /// Represents a class with no specific functionality.
    /// </summary>
    public static class Class1
    {
        /// <summary>
        /// Calculates the power of a given integer based on the target framework.
        /// </summary>
        /// <param name="value">The input value.</param>
        /// <returns>The calculated power.</returns>
        public static int Power(int value)
        {
#if NETSTANDARD2_0
            return value * 2;
#elif NET9_0
            return value * 3;
#endif
        }

        /// <summary>
        /// Adds two integers and returns the result.
        /// </summary>
        /// <param name="a">The first integer.</param>
        /// <param name="b">The second integer.</param>
        /// <returns>The sum of the two integers.</returns>
        public static int Add(int a, int b)
        {
            return a + b;
        }
    }
}
