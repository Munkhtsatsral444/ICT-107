class City {
  final String englishCountry;
  final String germanCountry;
  final String englishCity;
  final String germanCity;
  final String timeZoneId;

  const City({
    required this.englishCountry,
    required this.germanCountry,
    required this.englishCity,
    required this.germanCity,
    required this.timeZoneId,
  });

  String countryName(bool german) {
    return german ? germanCountry : englishCountry;
  }

  String cityName(bool german) {
    return german ? germanCity : englishCity;
  }
}

const List<City> majorCities = [
  City(
    englishCountry: 'Australia',
    germanCountry: 'Australien',
    englishCity: 'Sydney',
    germanCity: 'Sydney',
    timeZoneId: 'Australia/Sydney',
  ),
  City(
    englishCountry: 'Australia',
    germanCountry: 'Australien',
    englishCity: 'Perth',
    germanCity: 'Perth',
    timeZoneId: 'Australia/Perth',
  ),
  City(
    englishCountry: 'United Kingdom',
    germanCountry: 'Vereinigtes Königreich',
    englishCity: 'London',
    germanCity: 'London',
    timeZoneId: 'Europe/London',
  ),
  City(
    englishCountry: 'United States',
    germanCountry: 'Vereinigte Staaten',
    englishCity: 'New York',
    germanCity: 'New York',
    timeZoneId: 'America/New_York',
  ),
  City(
    englishCountry: 'Japan',
    germanCountry: 'Japan',
    englishCity: 'Tokyo',
    germanCity: 'Tokio',
    timeZoneId: 'Asia/Tokyo',
  ),
  City(
    englishCountry: 'Germany',
    germanCountry: 'Deutschland',
    englishCity: 'Berlin',
    germanCity: 'Berlin',
    timeZoneId: 'Europe/Berlin',
  ),

];