Schemas are retrieved from <https://git.sarepta.ehelse.no/publisert/standarder/-/tree/master/skjema>

Schemas are generated into the Root.cs file using the command below:

`.\xsd.exe ".\skjema_eresept_ER-M30-2014-12-01.xsd" ".\skjema_felleskomponenter_kith.xsd" ".\skjema_eresept_Forskrivning-2014-12-01.xsd" -outputdir:"..\..\Model\Fest" /classes /namespace:Fast.Data.Model.Fest /language:CS`

XSD.exe is not automatically added to the PATH. The default location is somewhere here: `C:\Program Files (x86)\Microsoft SDKs\Windows\{version}\bin\NETFX {version} Tools\`
