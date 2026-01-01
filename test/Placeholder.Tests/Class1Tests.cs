using Xunit;

namespace Placeholder
{
    public class Class1Tests
    {
        [Theory]
#if NET10_0
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
            var actual = Class1.Multiply(given);

            // Assert
            Assert.Equal(expected, actual);
        }

        [Fact]
        public void TestCompilerSwitches_OnCode()
        {
#if NET10_0
            Assert.Equal(3, Class1.Multiply(1));
#else
            Assert.Equal(2, Class1.Multiply(1));
#endif
        }
    }
}
