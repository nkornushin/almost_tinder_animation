import 'package:dating_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:location_permissions/location_permissions.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({Key key, this.user}) : super(key: key);

  final User user;

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage>  with SingleTickerProviderStateMixin {

  Animation animation;
  AnimationController animationController;

  @override
   void initState() {
     super.initState();
      animationController = AnimationController(
        duration: Duration(seconds: 10),
        vsync: this,
     );

    animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.slowMiddle));
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Hero(
              tag: 'avatar',
              child: Image.network(
                widget.user.image,
                fit: BoxFit.fill,
                height: 400,
                width: 400,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<LatLng>(
                
                future: _getCoordinates(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final km = Distance().as(LengthUnit.Kilometer,
                        snapshot.data, LatLng(widget.user.latitude, widget.user.longitude));
                    return FadeTransition(
                      opacity: animationController.drive(CurveTween(curve: Curves.easeOut)),
                      child:  Text(
                              '${widget.user.name} is $km km away from you!',
                              style: Theme.of(context).textTheme.headline,
                            ),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      'Please turn on the geolocation',
                      style: Theme.of(context).textTheme.headline,
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<LatLng> _getCoordinates() async {
    print('_getCoordinates');
    final permission = LocationPermissions();
    await permission.requestPermissions();

    final geolocator = Geolocator();
    final position = await geolocator.getLastKnownPosition(
        desiredAccuracy: LocationAccuracy.high);
        
    return LatLng(position.latitude, position.longitude);
  }
}
