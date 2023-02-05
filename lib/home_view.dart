import 'package:flutter/material.dart';
import 'sensor_view.dart';

// Home page - user selects exercise

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.title});

  final String title;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(onPressed: () => {
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child:
                          SensorViewPage(title: "Access Sensors")
                    );
                  }
              )
            },
                child: Text("Press me"),
            )

          ],
        ),
      ),
    );
  }
}
