using System;
using System.Diagnostics;
using System.IO;
using NUnit.Framework;

namespace Fast.Data.Tests
{
    public class Tests
    {
        const string Path = @"C:\Users\nilsh\Downloads\fest251\fest251.xml";

        [SetUp]
        public void Setup()
        {

        }

        [Test]
        public void Test1()
        {
            var sw = Stopwatch.StartNew();
            var data = FestParser.LoadFest(() => File.OpenRead(Path));
            Console.WriteLine(sw.Elapsed);
            Assert.That(data, Is.Not.Null);
            Assert.That(data.HentetDato, Is.GreaterThan(new DateTime(2021, 1, 1)));
        }
    }
}
