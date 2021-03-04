using System;
using System.IO;
using System.Xml.Serialization;
using Fast.Data.Model.Fest;

namespace Fast.Data
{
    public static class FestParser
    {
        public static FEST LoadFest(Func<Stream> openFile)
        {
            using var fileStream = openFile();
            var xmlSerializer = new XmlSerializer(typeof(FEST));
            var festData = (FEST)xmlSerializer.Deserialize(fileStream);
            return festData;
        }
    }
}
