using Xunit;

namespace Fake
{
    public class Class1Tests
    {
        [Theory]
#if NET9_0
        [InlineData(1, 3)]
        [InlineData(2, 6)]
        [InlineData(3, 9)]
#else
        [InlineData(1, 2)]
        [InlineData(2, 4)]
        [InlineData(3, 6)]
#endif
        public void TestCompilerSwitches_OnAttributes(int given, int expected)
        {
            // Act
            var result = Class1.Calculate(given);

            // Assert
            Assert.Equal(expected, result);
        }

        [Fact]
        public void TestCompilerSwitches_OnCode()
        {
#if NET462
            Assert.Equal(2, Class1.Calculate(1));
#elif NET47
            Assert.Equal(2, Class1.Calculate(1));
#elif NET471
            Assert.Equal(2, Class1.Calculate(1));
#elif NET472
            Assert.Equal(2, Class1.Calculate(1));
#elif NET48
            Assert.Equal(2, Class1.Calculate(1));
#elif NET481
            Assert.Equal(2, Class1.Calculate(1));
#elif NETCOREAPP3_1
            Assert.Equal(2, Class1.Calculate(1));
#elif NET5_0
            Assert.Equal(2, Class1.Calculate(1));
#elif NET6_0
            Assert.Equal(2, Class1.Calculate(1));
#elif NET7_0
            Assert.Equal(2, Class1.Calculate(1));
#elif NET8_0
            Assert.Equal(2, Class1.Calculate(1));
#elif NET9_0
            Assert.Equal(3, Class1.Calculate(1));
#endif
        }
    }
}
