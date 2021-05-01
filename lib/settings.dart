import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';


class SettingsRoute extends StatefulWidget {
  const SettingsRoute({Key key}) : super(key: key);
  @override
  _SettingsPage createState() => _SettingsPage();
}
enum COUNTRY {NE,BE}
COUNTRY _countryChoice = COUNTRY.NE;
SharedPreferences _myPrefs;

class _SettingsPage extends State<SettingsRoute> {
  @override
  void InitState()
  {
      getPrefs();
  }

  @override
  Widget build(BuildContext context){
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, 'fromSettings');
          return false;
        },
    // here we build the scaffold/body of the page
    child: Scaffold(

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

                  ListTile(
                    title: const Text('the Netherlands'),
                    leading: Radio<COUNTRY>(
                      value: COUNTRY.NE,
                      groupValue: _countryChoice,
                      onChanged: (COUNTRY value) {
                        setState(() {
                          _countryChoice = value;
                          _switchCountry();
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Belgium'),
                    leading: Radio<COUNTRY>(
                      value: COUNTRY.BE,
                      groupValue: _countryChoice,
                      onChanged: (COUNTRY value) {
                        setState(() {
                          _countryChoice = value;
                          _switchCountry();
                        });
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
     )
    );
  }

  void getPrefs () async {
    _myPrefs = await SharedPreferences.getInstance();
// TODO: als de prefs al op Belgie staan, dan de Belgie knop activeren
    String mySetting = _myPrefs.getString('currentCountry') ?? "Geen";
    log (mySetting);
  }


  void _switchCountry() async {
    final prefs = await SharedPreferences.getInstance();
    if (_countryChoice == COUNTRY.NE)
    {
      print('current country is the Netherlands');
      await prefs.setString('currentCountry', 'NE');
    }
    else if  (_countryChoice == COUNTRY.BE)
    {
      print('current country is  Belgium');
      await prefs.setString('currentCountry', 'BE');
    }
    String mySetting = prefs.getString('currentCountry') ?? "Geen";
    log (mySetting);
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
    //TODO  logout
  }
  String country;

}
