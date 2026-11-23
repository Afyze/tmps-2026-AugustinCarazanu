import Foundation

/// Saved copy of the official BNM rates of 05.11.2026 (EUR, USD, RON), in the
/// same XML format that bnm.md returns. Used with `--offline`, or when the
/// download fails, so the demo always runs.
enum SampleRates {
    static let date = "05.11.2026"

    static let xml = Data("""
    <?xml version="1.0" encoding="UTF-8"?>
    <ValCurs Date="05.11.2026" name="Official exchange rate">
      <Valute>
        <NumCode>978</NumCode>
        <CharCode>EUR</CharCode>
        <Nominal>1</Nominal>
        <Name>Euro</Name>
        <Value>20.1773</Value>
      </Valute>
      <Valute>
        <NumCode>840</NumCode>
        <CharCode>USD</CharCode>
        <Nominal>1</Nominal>
        <Name>US Dollar</Name>
        <Value>17.9274</Value>
      </Valute>
      <Valute>
        <NumCode>946</NumCode>
        <CharCode>RON</CharCode>
        <Nominal>1</Nominal>
        <Name>Romanian Leu</Name>
        <Value>3.7751</Value>
      </Valute>
    </ValCurs>
    """.utf8)
}
