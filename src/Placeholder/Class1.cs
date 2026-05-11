namespace Placeholder
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
        public static int Multiply(int value)
        {
#if NET10_0
            return value * 3;
#else
            return value * 2;
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

        /// <summary>
        /// Subtracts the second integer from the first and returns the result.
        /// </summary>
        /// <param name="a">The first integer.</param>
        /// <param name="b">The second integer.</param>
        /// <returns>The difference between the two integers.</returns>
        public static int Subtract(int a, int b)
        {
            return a - b;
        }
    }
}
