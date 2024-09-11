import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> launchGoogle(LatLng start, LatLng end) async {
  String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&origin=" +
      start.latitude.toString() +
      "," +
      start.longitude.toString() +
      "&destination=" +
      end.latitude.toString() +
      "," +
      end.longitude.toString();

  if (await canLaunchUrlString(googleMapsUrl)) {
    await launchUrl(Uri.parse(googleMapsUrl));
  } else {
    throw "Could not Launch $googleMapsUrl";
  }
}
