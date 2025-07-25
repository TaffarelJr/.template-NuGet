using Xunit;

namespace Fake
{
    public class Class1Tests
    {
        [Theory]
        [InlineData(1, 2)]
        [InlineData(2, 4)]
        [InlineData(3, 6)]
        public void Test1(int given, int expected)
        {
            // Act
            var result = Class1.Calculate(given);

            // Assert
            Assert.Equal(result, expected);
        }
    }
}
