using NUnit.Framework;
using Fast.Data;

namespace Fast.Service.Tests
{

    public class InteraksjonerTests
    {
        private FestService _sut;

        [OneTimeSetUp]
        public void OneTimeSetup()
        {
            _sut = new Fast.Service.FestService();

        }


        [Test]
        public void Interaksjoner_WithZyrtecId_ReturnsTwoInstancesOfSameInteraction()
        {
            var interaksjoner = _sut.FindInteraksjonVirkestoff(new string[] { "R06AE07" });
            Assert.That(interaksjoner, Has.Exactly(2).Items);
        }
    }
}
