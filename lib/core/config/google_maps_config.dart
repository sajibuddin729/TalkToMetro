/// Google Maps / Directions API key (Maps SDK + Routes API must be enabled in GCP).
const String googleMapsApiKey = String.fromEnvironment(
  'GOOGLE_MAPS_API_KEY',
  defaultValue: 'YOUR_GOOGLE_MAPS_API_KEY',
);

