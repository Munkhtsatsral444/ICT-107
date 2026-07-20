class City {
  final String cityEnglish;
  final String cityGerman;
  final String countryEnglish;
  final String countryGerman;
  final int utcOffset;

  const City({
    required this.cityEnglish,
    required this.cityGerman,
    required this.countryEnglish,
    required this.countryGerman,
    required this.utcOffset,
  });

  String cityName(bool german) {
    return german ? cityGerman : cityEnglish;
  }

  String countryName(bool german) {
    return german ? countryGerman : countryEnglish;
  }
}

const majorCities = [
  City(
    cityEnglish: 'Sydney',
    cityGerman: 'Sydney',
    countryEnglish: 'Australia',
    countryGerman: 'Australien',
    utcOffset: 10,
  ),
  City(
    cityEnglish: 'Berlin',
    cityGerman: 'Berlin',
    countryEnglish: 'Germany',
    countryGerman: 'Deutschland',
    utcOffset: 2,
  ),
  City(
    cityEnglish: 'London',
    cityGerman: 'London',
    countryEnglish: 'United Kingdom',
    countryGerman: 'Vereinigtes Königreich',
    utcOffset: 1,
  ),
  City(
    cityEnglish: 'New York',
    cityGerman: 'New York',
    countryEnglish: 'United States',
    countryGerman: 'Vereinigte Staaten',
    utcOffset: -4,
  ),
  City(
    cityEnglish: 'Tokyo',
    cityGerman: 'Tokio',
    countryEnglish: 'Japan',
    countryGerman: 'Japan',
    utcOffset: 9,
  ),
];