import 'package:flutter/material.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

const String kakaoMapKey = '096bea75f9d0374f3c939bff68e78cd3'; //자바스크립트 key

class FestInfo {
  double lat;
  double lng;
  String name;
  String info;
  FestInfo(this.lat, this.lng, this.name, this.info);
}

class MyLocation extends StatefulWidget {
  const MyLocation({Key? key}) : super(key: key);

  @override
  State<MyLocation> createState() => _MyLocationState();
}

class _MyLocationState extends State<MyLocation> {
  WebViewController? _mapController;
  double initLng = 127.459223;
  double initLat = 36.6283933;
  String location = " ";

  List festList = <FestInfo>[
    FestInfo(36.6183933, 127.469223, "festival1", "페스티벌 일정에 관한 내용"),
    FestInfo(36.6383933, 127.259223, "festival2", "페스티벌 일정에 관한 내용"),
    FestInfo(36.6483933, 127.419223, "festival3", "페스티벌 일정에 관한 내용"),
    FestInfo(36.7283933, 127.440223, "festival4", "페스티벌 일정에 관한 내용"),
    FestInfo(36.6883933, 127.420223, "festival5", "페스티벌 일정에 관한 내용"),
    FestInfo(36.6283933, 127.473223, "festival6", "페스티벌 일정에 관한 내용"),
  ];

  // List festList = [
  //   [36.6183933, 127.469223, "festival1"],
  //   [36.6383933, 127.259223, "festival2"],
  //   [36.6483933, 127.419223, "festival3"],
  //   [36.7283933, 127.440223, "festival4"],
  // ];

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      initLat = position.latitude;
      initLng = position.longitude;
    });

    List<Placemark> placemarks =
        await placemarkFromCoordinates(initLat, initLng);
    setState(() {
      location = placemarks[0].street.toString();
    });

    myLocationMaker();
  }

  void myLocationMaker() {
    _mapController?.runJavascript('''
        marker.setMap(null);
        var imageSrc = 'https://cdn-icons-png.flaticon.com/512/684/684908.png';                            
        var imageSize = new kakao.maps.Size(28, 30);                
        var imageOption = {offset: new kakao.maps.Point(17, 36)}; 

        addMarker(new kakao.maps.LatLng($initLat , $initLng));

        function addMarker(position) {
            let testMarker = new kakao.maps.Marker({position: position,
              image: new kakao.maps.MarkerImage(imageSrc, imageSize, imageOption)});

            testMarker.setMap(map);
        }
        var moveLatLon = new kakao.maps.LatLng($initLat, $initLng);
    
        map.setCenter(moveLatLon);
''');
  }

  void markFestivals() {
    print('markFestivals');
    _mapController?.runJavascript(''' 
            var imageSrc = 'https://cdn-icons-png.flaticon.com/512/149/149059.png';                             
            var imageSize = new kakao.maps.Size(28, 30);                
            var imageOption = {offset: new kakao.maps.Point(17, 36)};    
      
            function addMarker(position, name, info) {
              let testMarker = new kakao.maps.Marker({position: position,
              image: new kakao.maps.MarkerImage(imageSrc, imageSize, imageOption)});

              testMarker.setMap(map); 
              // console.log(name.);
              kakao.maps.event.addListener(testMarker, 'click', function (mouseEvent) {
                                           onTapMarker.postMessage(name+'-'+info);
              });


             }

            // for(let i=0; i<${festList.length}; i++){
            //   addMarker(new kakao.maps.LatLng(${festList[0].lat} , ${festList[0].lng}));
            // }
            addMarker(new kakao.maps.LatLng(${festList[0].lat} , ${festList[0].lng}), `${festList[0].name}`, `${festList[0].info}`);
            addMarker(new kakao.maps.LatLng(${festList[1].lat} , ${festList[1].lng}), `${festList[1].name}`, `${festList[1].info}`);
            addMarker(new kakao.maps.LatLng(${festList[2].lat} , ${festList[2].lng}), `${festList[2].name}`, `${festList[2].info}`);
            addMarker(new kakao.maps.LatLng(${festList[3].lat} , ${festList[3].lng}), `${festList[3].name}`, `${festList[3].info}`);
            addMarker(new kakao.maps.LatLng(${festList[4].lat} , ${festList[4].lng}), `${festList[4].name}`, `${festList[4].info}`);
            addMarker(new kakao.maps.LatLng(${festList[5].lat} , ${festList[5].lng}), `${festList[5].name}`, `${festList[5].info}`);
    ''');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _determinePosition().then((value) => markFestivals());
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        address(),
        KakaoMapView(
          mapController: (controller) {
            _mapController = controller;
          },
          width: size.width,
          height: 400,
          kakaoMapKey: kakaoMapKey,
          showMapTypeControl: true,
          showZoomControl: true,
          draggableMarker: true,
          zoomLevel: 7,
          lat: initLat,
          lng: initLng,
          onTapMarker: (message) {
            var fest = message.message.split('-');
            String name = fest[0];
            String info = fest[1];
            festivalInfo(context, name, info).then((value) {
              setState(() {});
            });
          },
          zoomChanged: (p0) {
            print(p0.message);
            //level 9에서부터 marker 지우기
            int level = int.parse(p0.message);
            if (level > 9) {
              _mapController?.runJavascript('''
                  marker.setMap(null);
              ''');
            } else {
              myLocationMaker();
            }
          },
        ),
      ],
    );
  }

  Future<void> festivalInfo(BuildContext context, String name, String info) {
    return showModalBottomSheet<void>(
      //디자인 수정 -> api 보는거 보고
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, setState) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          '페스티벌 이름: $name',
                          style: TextStyle(fontSize: 22),
                        ),
                        Divider(
                          height: 20,
                          thickness: 1,
                          color: Color.fromRGBO(95, 95, 95, 0.5),
                        ),
                        Text(
                          '페스티벌 내용: $info',
                          style: TextStyle(height: 1.5, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ));
      },
    );
  }

  Container address() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.only(left: 5),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 5),
            child: Icon(
              Icons.location_on_outlined,
              size: 20,
            ),
          ),
          Flexible(
              flex: 5,
              child: Text(
                '현위치: ',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              )),
          Flexible(
              flex: 12,
              child: Text(location,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)))
        ],
      ),
    );
  }
}
