import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:recipes/auth/auth.dart';


//created stf 
class MapsPage extends StatefulWidget {
  MapsPage({this.auth});
  final BaseAuth auth;
  @override
  MapsPageState createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  //instance GoogleMap
  Completer<GoogleMapController> _controller = Completer();
  String usuario = 'Usuario';
  String usuarioEmail = 'Email';
  String id;
  
  

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,

            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(target: LatLng(-23.533773, -46.625290), zoom: 10),
              onMapCreated: (GoogleMapController controller) { 
                _controller.complete(controller);
              },
              markers: {
               brazil1Marker,
               brazil2Marker,
               brazil3Marker,
               calixtoMarker,
               brazilMarker,
               manboMarker
              },
            ),
          ),
          _buildContainer(),
        ],
      ),
    );
  }

  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 130.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://thebrazilbusiness.com/www/images/media/700_394/1040352461683.jpg",
                  -23.5516249,
                  -46.6778654,
                  "Grosery Brazil"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://upload.wikimedia.org/wikipedia/commons/1/13/Supermarkt.jpg",
                  -23.5516249,
                  -46.6778654,
                  "Le Calixto"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(
                  "https://food.fnr.sndimg.com/content/dam/images/food/secured/fullset/2014/4/17/0/GK0200_BTS_produce-section_s4x3.jpg.rend.hgtvcom.966.725.suffix/1397761349158.jpeg",
                  -23.6255542,
                  -46.7498354,
                  "Store Sao Paulo"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boxes(String _image, double lat, double long, String siteName) {
    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
      },
      child: Container(
        child: new FittedBox(
          child: Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(2.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 180,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(24.0),
                      child: Image(
                        fit: BoxFit.fill,
                        image: NetworkImage(_image),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: myDetailsContainer1(siteName),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget myDetailsContainer1(String siteName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              child: Text(
            siteName,
            style: TextStyle(
                color: Colors.blue,
                fontSize: 24.0,
                fontWeight: FontWeight.bold),
          )),
        ),
        SizedBox(height: 5.0),
        Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
                child: Text(
              "Opens 7:00 am",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 18.0,
              ),
            )),            
            Container(
                child: Text(
              "Close 22 pm",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 18.0,
              ),
            )),
          ],
        )),
        SizedBox(height: 5.0),
        
        Container(
            child: Text(
          "St 76 Av 52 Bill",
          style: TextStyle(
              color: Colors.black54,
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        )),
      ],
    );
  }



  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 15,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }
}

// marcadores

Marker manboMarker = Marker(
  markerId: MarkerId('Supermarkets'),
  position: LatLng(-23.5785739, -46.6771112),
  infoWindow: InfoWindow(title: 'Mambo - Moema'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueRed,
  ),
);

Marker calixtoMarker = Marker(
  markerId: MarkerId('Calixto'),
  position: LatLng(-23.5516249, -46.6778654),
  infoWindow: InfoWindow(title: 'Fair Benedito Calixto'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueOrange
  ),
);
Marker brazilMarker = Marker(
  markerId: MarkerId('brazil'),
  position: LatLng(-23.5464997, -46.7602705),
  infoWindow: InfoWindow(title: 'Market Brazil'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueMagenta
  ),
);

//Brazil Marker

Marker brazil1Marker = Marker(
  markerId: MarkerId('brazil1'),
  position: LatLng(-23.5785739, -46.6771112),
  infoWindow: InfoWindow(title: 'Supermarkets'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueOrange,
  ),
);
Marker brazil2Marker = Marker(
  markerId: MarkerId('brazil2'),
  position: LatLng(-23.5785739, -46.6771112),
  infoWindow: InfoWindow(title: 'Mercado Municipal de São Paulo'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueMagenta,
  ),
);
Marker brazil3Marker = Marker(
  markerId: MarkerId('brazil3'),
  position: LatLng(-23.5458521, -46.6466167),
  infoWindow: InfoWindow(title: 'market Kinjo Yamato'),
  icon: BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueMagenta,
  ),
);
