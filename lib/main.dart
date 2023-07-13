// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:geofence/data3.dart';
import 'package:latlong2/latlong.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Map GeoJson Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // instantiate parser, use the defaults
  GeoJsonParser myGeoJson = GeoJsonParser(
      defaultMarkerColor: Colors.red,
      defaultPolygonBorderColor: Colors.red,
      defaultPolygonFillColor: Colors.red.withOpacity(0.1));
  bool loadingData = false;

  // this is callback that gets executed when user taps the marker
  void onTapMarkerFunction(Map<String, dynamic> map) {
    // ignore: avoid_print
    print('onTapMarkerFunction: $map');
  }

  Future<void> processData() async {
    // parse a small test geoJson
    // normally one would use http to access geojson on web and this is
    // the reason why this funcyion is async.
    myGeoJson.parseGeoJsonAsString(testGeoJson);
  }

  @override
  void initState() {
    myGeoJson.setDefaultMarkerTapCallback(onTapMarkerFunction);
    loadingData = true;
    Stopwatch stopwatch2 = Stopwatch()..start();
    processData().then((_) {
      setState(() {
        loadingData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GeoJson Processing time: ${stopwatch2.elapsed}'),
          duration: const Duration(milliseconds: 5000),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: FlutterMap(
          mapController: MapController(),
          options: MapOptions(
            center: LatLng(45.993807, 14.483972),
            //center: LatLng(45.720405218, 14.406593302),
            zoom: 14,
          ),
          children: [
            TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c']),
            //userAgentPackageName: 'dev.fleaflet.flutter_map.example',
            loadingData
                ? const Center(child: CircularProgressIndicator())
                : PolygonLayer(
                    polygons: myGeoJson.polygons,
                  ),
            if (!loadingData) PolylineLayer(polylines: myGeoJson.polylines),
            if (!loadingData) MarkerLayer(markers: myGeoJson.markers)
          ],
        ));
  }
}