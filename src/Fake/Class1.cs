namespace Fake
{
    /// <summary>
    /// Represents a class with no specific functionality.
    /// </summary>
    public static class Class1
    {
        /// <summary>
        /// Performs a calculation on the provided value.
        /// </summary>
        /// <param name="value">The input value.</param>
        /// <returns>The calculated result.</returns>
        public static int Calculate(int value)
        {
#if NETSTANDARD2_0
            return value * 2;
#elif NET9_0
            return value * 3;
#endif
        }
    }
}
