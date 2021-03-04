# Fast

## Hva er Fast?

Fast er en rask måte å finne interkasjoner mellom legemidler.

Den er bygget på FEST datasettet i fra legemiddelverket <https://legemiddelverket.no/andre-temaer/fest>.

## Hvorfor?

For å lære arbeid med XML Schema, Dotnet 5 og Elm.

## Utvikling

For å kjøre løsningen må du

1. Laste ned FAST databasen.
   - <https://legemiddelverket.no/andre-temaer/fest/nedlasting-av-fest>
2. Hardkode filbanen til `fast.xml` i FestService constructor
3. Starte Api Servicen (http://localhost:5000)
4. Starte Web
   - `npm install`
   - `npx elm-app start`
