import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class MapScreen extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final List<dynamic> businesses;

  const MapScreen({
    Key? key,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.businesses,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double _zoomLevel = 12.5; // Zoom initial
  late MapZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    // Centrer la carte sur la ville avec un zoom ajusté
    _zoomPanBehavior = MapZoomPanBehavior(
      enableDoubleTapZooming: true,
      enablePanning: true,
      zoomLevel: _zoomLevel,
      focalLatLng: MapLatLng(widget.initialLatitude, widget.initialLongitude),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0), // Bord arrondis
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2), // Ombre légère
              ),
            ],
          ),
          child: SfMaps(
            layers: [
              MapTileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                zoomPanBehavior: _zoomPanBehavior,
                initialMarkersCount: widget.businesses.length,
                markerBuilder: (BuildContext context, int index) {
                  final business = widget.businesses[index];

                  String label = business['rating'] != null
                      ? business['rating'].toString()
                      : "N/A"; // Si la note est nulle, afficher "N/A"

                  return MapMarker(
                    latitude: business['coordinates']['latitude'],
                    longitude: business['coordinates']['longitude'],
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Marqueur (pin)
                        Icon(
                          Icons.location_on,
                          color: Colors.black,
                          size: 52,
                        ),
                        // Label avec la note
                        Positioned(
                          bottom: 5,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
