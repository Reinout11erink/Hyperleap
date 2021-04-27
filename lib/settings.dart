import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
class SettingsRoute extends StatefulWidget {
  const SettingsRoute({Key key}) : super(key: key);
  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsRoute> {
  @override
  Widget build(BuildContext context){
    // here we build the scaffold/body of the page
    return Scaffold(

      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text('Settings',style: TextStyle(color: Colors.black),),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              margin: const EdgeInsets.all(8.0),
              color: Colors.blue,
              child: ListTile(
                //when tapped invokes the logout function (which has not been written yet)
                onTap: (){
                  _logout(){
                  }
                },
                title: Text("Log out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),),
                trailing: Icon(Icons.logout, color: Colors.white,),
              ),
            ),
            const SizedBox(height: 10.0),
            Card(
              elevation: 4.0,
              margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 16.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    value: true,
                    title: Text("Toggle Availability"),
                  ),

                  Container(
                      child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.add_location_outlined),
                                Text('Change country'),

                                new Radio(
                                  groupValue: 0,
                                  value: 0,
                                ),
                                new Text(
                                  'NL',
                                  style: new TextStyle(fontSize: 16.0),
                                ),
                                new Radio(
                                  value: 1,
                                ),
                                new Text(
                                  'BE',
                                  style: new TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                          ]))
                ]
                ,
              ),
            )
          ],
        ),
      ),
    );
  }
  void _switchCountry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool country = (prefs.getBool('currentCountry'));
    if (country == true) {
      print('current country is the netherlands');
      country = false;
    }
    else {
      print('current country is the Belgium');
      country = true;
    }
    await prefs.setBool('currentCountry', country);
  }

  // void _toggleAvailiablity() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool country = (prefs.getBool('currentCountry'));
  //   if (country == true) {
  //     print('current country is the netherlands');
  //     country = false;
  //   }
  //   else {
  //     print('current country is the Belgium');
  //     country = true;
  //   }
  //   await prefs.setBool('currentCountry', country);
  // }

  //logging in and out is not yet implemented so this function can't be written yet
  void _logout() {
    //TODO
  }
  String country;

}
