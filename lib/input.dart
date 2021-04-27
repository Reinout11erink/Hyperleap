import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

class InputRoute extends StatefulWidget {
  const InputRoute({Key key}) : super(key: key);
  @override
  _InputPage createState() => _InputPage();
}

class City {
  final String stadID;
  final String city;

  City({this.stadID,this.city});

  factory City.fromJason(Map<String, dynamic> json) {
    return City(
        stadID: json['cityID'] as String,
        city: json['city'] as String
    );
  }
}

class Cinema {
  final String cinemaID;
  final String cinema_title;
  final String cityID;

  Cinema({this.cinemaID,this.cinema_title,this.cityID});

  factory Cinema.fromJason(Map<String, dynamic> json) {
    return Cinema(
        cinemaID: json['cinemaID'] as String,
        cinema_title: json['cinema_title'] as String,
        cityID: json['cityID'] as String
    );
  }
}

class Film {
  final String filmID;
  final String film_title;
  final String film_poster_url;
  final String film_rating;
  final String film_duration;

  Film({this.filmID,this.film_title, this.film_poster_url, this.film_rating, this.film_duration });

  factory Film.fromJason(Map<String, dynamic> json) {
    return Film(
        filmID: json['filmID'] as String,
        film_title: json['film_title'] as String,
        film_poster_url: json['film_poster_url'] as String,
        film_rating: json['film_rating'] as String,
        film_duration: json['film_duration'] as String,
    );
  }
}

class Planning {
  final String planningID;
  final String filmID;
  final String cinemaID;
  final DateTime dtBegin;

  Planning({this.planningID, this.filmID, this.cinemaID, this.dtBegin});

  factory Planning.fromNew(String film, String cinema, DateTime dt)
  {
     return Planning (
        filmID: film,
        cinemaID: cinema,
        dtBegin: dt
     );
  }

  factory Planning.fromJason(Map<String, dynamic> json) {
    return Planning(
        planningID: json['planningID'] as String,
        filmID: json['filmID'] as String,
        cinemaID: json['cinemaID'] as String,
        dtBegin: json['dtBegin'] as DateTime
    );
  }
}

class Week {
  final String WeekNumber;
  final String WeekDescription;
  final DateTime DateFrom;
  final DateTime DateUntil;

  Week({this.WeekNumber,this.WeekDescription,this.DateFrom,this.DateUntil});

  factory Week.fromWeekNumber(int WeekNo, DateTime firstThursday) {
    var dur = Duration(days: ((WeekNo) *7),
                       hours: 0,
                       minutes: 0);
    DateTime date1 = firstThursday.add(dur);
    if (date1.hour > 0)
    {
         date1 = date1.subtract(Duration(hours: date1.hour));
    }
    dur = Duration(days: 6);
    DateTime date2 = date1.add(dur);
    var desc = WeekNo.toString() + " ("  + date1.day.toString() + "-" + date1.month.toString() + "-"  + date1.year.toString()  + " to " + date2.day.toString() + "-" + date2.month.toString() + "-"  + date2.year.toString()  + ")";
    return Week(
        WeekNumber: WeekNo.toString(),
        WeekDescription:  desc,
        DateFrom: date1,
        DateUntil: date2,
    );
  }
}

class _InputPage extends State<InputRoute> {
  final myController = TextEditingController();
  List<DropdownMenuItem<City>> _dropDownCityItems;
  City _selectedCity;
  List<DropdownMenuItem<Cinema>> _dropDownCinemaItems;
  Cinema _selectedCinema;
  List<Film> _listFilms;
  List<DropdownMenuItem<Film>> _dropDownFilmItems;
  Film _selectedFilm;
  List<DropdownMenuItem<Week>> _dropDownWeekItems;
  Week _selectedWeek;
  DateTime firstDayOfYear = new DateTime(DateTime.now().year);
  DateTime firstThursdayOfYear;
  String countrySetting;
  FocusNode _focusNode;
  //controllers for text fields
  TextEditingController thu1 = TextEditingController();
  TextEditingController thu2 = TextEditingController();
  TextEditingController thu3 = TextEditingController();
  TextEditingController thu4 = TextEditingController();
  TextEditingController thu5 = TextEditingController();
  TextEditingController fri1 = TextEditingController();
  TextEditingController fri2 = TextEditingController();
  TextEditingController fri3 = TextEditingController();
  TextEditingController fri4 = TextEditingController();
  TextEditingController fri5 = TextEditingController();
  TextEditingController sat1 = TextEditingController();
  TextEditingController sat2 = TextEditingController();
  TextEditingController sat3 = TextEditingController();
  TextEditingController sat4 = TextEditingController();
  TextEditingController sat5 = TextEditingController();
  TextEditingController sun1 = TextEditingController();
  TextEditingController sun2 = TextEditingController();
  TextEditingController sun3 = TextEditingController();
  TextEditingController sun4 = TextEditingController();
  TextEditingController sun5 = TextEditingController();
  TextEditingController mon1 = TextEditingController();
  TextEditingController mon2 = TextEditingController();
  TextEditingController mon3 = TextEditingController();
  TextEditingController mon4 = TextEditingController();
  TextEditingController mon5 = TextEditingController();
  TextEditingController tue1 = TextEditingController();
  TextEditingController tue2 = TextEditingController();
  TextEditingController tue3 = TextEditingController();
  TextEditingController tue4 = TextEditingController();
  TextEditingController tue5 = TextEditingController();
  TextEditingController wed1 = TextEditingController();
  TextEditingController wed2 = TextEditingController();
  TextEditingController wed3 = TextEditingController();
  TextEditingController wed4 = TextEditingController();
  TextEditingController wed5 = TextEditingController();


  List<DropdownMenuItem<City>> buildDropDownCityItems() {
    List<DropdownMenuItem<City>> items = new List<DropdownMenuItem<City>>();
    makeList(List<City> cities)
    {
        int i = 0;
        cities.forEach((City _city) {
          items.add( DropdownMenuItem(child: Text(_city.city), value: _city),);
       });
    }
    handleError(Error _e){
      log("Error bij ophalen films");
    }

    Future<List<City>> futurejsonList = getCities(countrySetting);
//    List<City> citylist;
    futurejsonList..then((value) { makeList(value);},
        onError:  (e) { handleError(e); }
    );
    return items;
  }

  List<DropdownMenuItem<Cinema>> buildDropDownCinemaItems() {
    List<DropdownMenuItem<Cinema>> cinemaItems = new List<DropdownMenuItem<Cinema>>();
    makeList(List<Cinema> cinemas) {
      cinemas.forEach((Cinema _cinema) {
         cinemaItems.add( DropdownMenuItem(child: Text(_cinema.cinema_title), value: _cinema),);
        //        log (' items' + items[index].child.toString());
        //        index += 1;
      });
    }
    handleError(Error e){
       log("Error bij ophalen cinema's");
     }
    Future<List<Cinema>> futurejsonList = getCinemas(_selectedCity.stadID);
    futurejsonList..then((value) {
      makeList(value);
      setState(() {
        Week w = _selectedWeek;
        _selectedWeek = null;
        _selectedWeek = w;
      });
      },
        onError: (e) { handleError(e); }
    );
    return cinemaItems;
  }

  List<DropdownMenuItem<Film>> getFilmList() {
    List<DropdownMenuItem<Film>> filmItems = new List<DropdownMenuItem<Film>>();
    makeList(List<Film> _films)
    {
        _listFilms = _films;
        _films.forEach((Film _film)
        {
           filmItems.add (DropdownMenuItem(child: Text(_film.film_title), value: _film),);
        });
    }
    handleError(Error _e){
      log("Error bij ophalen films");
    }
    Future<List<Film>> futureJsonList = getFilms();
    futureJsonList..then((value) { makeList(value);
        setState(() {
         Week w = _selectedWeek;
         _selectedWeek = null;
         _selectedWeek = w;
        });

    },
          onError: (e) { handleError(e); }
          );
   return filmItems;
  }

  int numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));

    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  int calcWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int woy =  ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = numOfWeeks(date.year - 1);
    } else if (woy > numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
  }

  List<DropdownMenuItem<Week>> getWeekList()  {
    List<DropdownMenuItem<Week>> weekItems = new  List<DropdownMenuItem<Week>>();
    int weekNow = calcWeekNumber(DateTime.now());
    Week week;

    for(int i=weekNow;i<=weekNow + 30; i++)
    {
      if (i>numOfWeeks(DateTime.now().year))
      {
        week = Week.fromWeekNumber(i-numOfWeeks(DateTime.now().year), firstThursdayOfYear);
      }
      else
      {
        week = Week.fromWeekNumber(i, firstThursdayOfYear);
      }
      weekItems.add (DropdownMenuItem(child: Text(week.WeekDescription), value: week));
    }

    return weekItems;
  }

  void saveToDatabase()  {
     DateTime getNextDate(DateTime d)
     {
         var dur = Duration (days: 1, hours: 0, minutes: 0, seconds: 0, milliseconds: 0, microseconds: 0);
         return d.add(dur);
     }
     DateTime getCineDateTime(DateTime d, String t)
     {
         int hh = 0;
         int mm = 0;
         int dd = 0;
         String shh = "";
         String smm = "";
         if (t.contains("."))
         {
            shh = t.substring(0,t.indexOf("."));
            smm = t.substring(t.indexOf(".") + 1);
         }
         else if (t.contains(":") )
         {
           shh = t.substring(0,t.indexOf(":"));
           smm = t.substring(t.indexOf(":") + 1);
         }
         else if (t.contains("u"))
         {
           shh = t.substring(0,t.indexOf("u"));
           smm = t.substring(t.indexOf("u") + 1);
         }
         else
         {
           shh = t;
         }

         if (smm != "")
         {
            mm = num.tryParse(smm);
         }
         hh = num.tryParse(shh);
         log (" conv hh: " + hh.toString());
         if (hh != null && mm != null && hh <= 23 && mm <= 59)
         {
           if (hh <= 2)
             dd = 1;
           var dur = Duration(days: dd,
               hours: hh,
               minutes: mm,
               seconds: 0,
               milliseconds: 0,
               microseconds: 0);
               return d.add(dur);
         }
         else
         {
            // TODO: error
         }
         return d;
     }
     TextEditingController tc = TextEditingController();
     // controleer dat Cinema ID, Film Id en Week zijn gevuld
     if (  _selectedWeek   != null && _selectedWeek.WeekNumber != ""
        && _selectedCinema != null && _selectedCinema.cinemaID != ""
        && _selectedFilm   != null && _selectedFilm.filmID != ""
        )
     {
       var date = _selectedWeek.DateFrom;

       log('selected city is: ' + _selectedCity.city + " (" +
           _selectedCity.stadID + ")");
       log('selected film is: ' + _selectedCinema.cinema_title + " (" +
           _selectedCinema.cinemaID + ")");
       log('selected film is: ' + _selectedFilm.film_title + " (" +
           _selectedFilm.filmID + ")");
       log('selected week is: ' + _selectedWeek.WeekNumber);
       log (" Datum = " + date.toString());
       int aant = 0;
       // loop door alle textcontrollers heen; als de waarde niet null is, dan moet er een regel in de database worden toegevoegd
       for (int i = 1; i <= 7; i++) {
         for (int j = 1; j <= 5; j++) {
           tc = getController(i, j);
           if (tc.text != null && tc.text != "") {
             DateTime cineDateTime = getCineDateTime(date, tc.text);
             aant++;
             Planning plan;
             plan =  Planning.fromNew (_selectedFilm.filmID, _selectedCinema.cinemaID, cineDateTime);
             Future<bool> futureSucces = insertPlanning(plan);
           }
         }
         date = getNextDate(date);
         if (date.hour > 0)
         {
           date = date.subtract(Duration(hours: date.hour));
         }
       }
       if (aant == 0)
       {
          log("Geen tijden ingevuld: er is niets opgeslagen");
       }
       else
       {
          log(aant.toString() + " tijden opgeslagen");
       }
     }
     else
     {
        // TODO: foutafhandeling
        log("Selecteer eerst een bioscoop, een film en een week");
     }
  }

  TextEditingController getController (int day, int fieldno)  {
     if (day == 1)
     {
       if (fieldno == 1) return thu1;
       else if (fieldno == 2) return thu2;
       else if (fieldno == 3) return thu3;
       else if (fieldno == 4) return thu4;
       else return thu5;
     }
     else if (day == 2)
     {
       if (fieldno == 1) return fri1;
       else if (fieldno == 2) return fri2;
       else if (fieldno == 3) return fri3;
       else if (fieldno == 4) return fri4;
       else return fri5;
     }
     else if (day == 3)
     {
       if (fieldno == 1) return sat1;
       else if (fieldno == 2) return sat2;
       else if (fieldno == 3) return sat3;
       else if (fieldno == 4) return sat4;
       else return sat5;
     }
     else if (day == 4)
     {
       if (fieldno == 1) return sun1;
       else if (fieldno == 2) return sun2;
       else if (fieldno == 3) return sun3;
       else if (fieldno == 4) return sun4;
       else return sun5;
     }
     else if (day == 5)
     {
       if (fieldno == 1) return mon1;
       else if (fieldno == 2) return mon2;
       else if (fieldno == 3) return mon3;
       else if (fieldno == 4) return mon4;
       else return mon5;
     }
     else if (day == 6)
     {
       if (fieldno == 1) return tue1;
       else if (fieldno == 2) return tue2;
       else if (fieldno == 3) return tue3;
       else if (fieldno == 4) return tue4;
       else return tue5;
     }
     else  // day == 7
     {
       if (fieldno == 1) return wed1;
       else if (fieldno == 2) return wed2;
       else if (fieldno == 3) return wed3;
       else if (fieldno == 4) return wed4;
       else return wed5;
     }
  }

  bool checkInputValue(String time)  {
     bool check = true;
     if (time != "") {
       int hh = 0;
       int mm = 0;
       int dd = 0;
       String shh = "";
       String smm = "";
       if (time.contains(".")) {
         shh = time.substring(0, time.indexOf("."));
         smm = time.substring(time.indexOf(".") + 1);
       }
       else if (time.contains(":")) {
         shh = time.substring(0, time.indexOf(":"));
         smm = time.substring(time.indexOf(":") + 1);
       }
       else if (time.contains("u")) {
         shh = time.substring(0, time.indexOf("u"));
         smm = time.substring(time.indexOf("u") + 1);
       }
       else {
         shh = time;
       }

       if (smm != "") {
         mm = num.tryParse(smm);
       }
       hh = num.tryParse(shh);
       if (!(hh != null && mm != null && hh <= 23 && mm <= 59)) {
         check = false;
       }
     }
     return check;
  }

  void clearAllFields() {
    TextEditingController tc;
    for (int i = 1; i <= 7; i++) {
      for (int j = 1; j <= 5; j++) {
        tc = getController(i, j);
        if (tc.text != null && tc.text != "") {
          tc.text = "";
        }
      }
    }
  }

  void copyFields()  {
    TextEditingController tcOrig;
    TextEditingController tcCopy;
    for (int i = 1; i <= 5; i++)
    {
      tcOrig = getController(1, i);
      log(tcOrig.text);
      for (int j = 2; j <= 7; j++)
      {
         if (tcOrig.text != null && tcOrig.text != "")
          {
             tcCopy = getController(j, i);
             if (tcCopy.text == null || tcCopy.text == "" )
             {
               tcCopy.text = tcOrig.text;
             }
          }

      }
    }
  }

  Widget _buildInputfield(int cineDay, int fieldNo) {
    var textControl = getController(cineDay, fieldNo);
    InputDecoration inputDecNoBorder = InputDecoration(
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0), ), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.0), ),
//      hintText: '',
      );
    InputDecoration inputDecError = InputDecoration(
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2.0),),enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0),),
 //     errorMaxLines: 1
      );
    InputDecoration currentInputDec = inputDecNoBorder;
    bool boolFocus = false;
    if (cineDay == 1 && fieldNo ==1) {
      boolFocus = true;
    }

    return Container(
        margin: EdgeInsets.all(7.0),
//        alignment: Alignment.center,
        width: 59.0,
        height: 23.0,
        color: Colors.white,
        child: TextFormField(
          validator: (value) {
            if (!checkInputValue(value)) {
               currentInputDec = inputDecError;
               return "";
            }
            return null;
          },
          controller: textControl,
          decoration: currentInputDec,
          keyboardType: TextInputType.numberWithOptions(),
          style: TextStyle(fontSize: 10.5,  height: 1.0, color: Colors.black),
          autovalidateMode: AutovalidateMode.onUserInteraction,
//          autofocus: boolFocus,
          )
    );
  }

  void initState() {
    super.initState();
    // TODO: Setting ophalen uit settings voor land (Nederland NL of Belgie BE), voor nu even hardgecodeerd Kop NL
    countrySetting = "NL";
    firstThursdayOfYear= new DateTime( firstDayOfYear.year, 1, 5 - firstDayOfYear.weekday);
    _dropDownWeekItems = getWeekList();
    _dropDownCityItems = buildDropDownCityItems();
    _dropDownFilmItems = getFilmList();
    new Timer(new Duration(milliseconds:10), ()
    {
      setState(() {
      });
    });
    _selectedWeek = _dropDownWeekItems[1].value;
    new Timer(new Duration(milliseconds:1000), ()
    {
      setState(() {
         Week w = _selectedWeek;
         _selectedWeek = null;
         _selectedWeek = w;
      });
    });
    new Timer(new Duration(milliseconds:1500), ()
    {
      setState(() {
        Week w = _selectedWeek;
        _selectedWeek = null;
        _selectedWeek = w;
      });
    });

   }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text('Manual Data Input', style: TextStyle(color: Colors.black)),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pushNamed(context, 'settings');
            },
          )
        ],
      ),
      body:   SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.calendar_today),
                  Text(' Week Select ',
                      style:
                      TextStyle(
                          color: Colors.purple, fontWeight: FontWeight.w900)),
                  DropdownButton<Week>(
                    value: _selectedWeek,
                    items: _dropDownWeekItems,
                    onChanged: (value)
                    {
                      setState(()
                      {
                        _selectedWeek= value;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.location_city),
                  Text(' City ',
                      style: TextStyle(
                          color: Colors.purple, fontWeight: FontWeight.w900)),
                  DropdownButton<City>(
                    value: _selectedCity,
                    items: _dropDownCityItems,
                    onChanged: (value)
                    {
                      _selectedCity = value;
                      //TODO: error bij het selecteren van een andere stad; gaat niet goed bij het opnieuw opbouwen van de CinemaItems dropdownlijst
                      _dropDownCinemaItems = buildDropDownCinemaItems();
                      new Timer(new Duration(milliseconds:1000), ()
                      {
                        setState(() {
                           Week w = _selectedWeek;
                           _selectedWeek = null;
                           _selectedWeek = w;
                        });
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.account_balance),
                  Text(' Cinema ',
                      style: TextStyle(
                          color: Colors.purple, fontWeight: FontWeight.w900)),
                  DropdownButton<Cinema>(
                    value: _selectedCinema,
                    items: _dropDownCinemaItems,
                    onChanged: (value)
                    {
                      setState(()
                      {
                        _selectedCinema = value;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.star),
                  Text(' Film Title ',
                      style: TextStyle(
                          color: Colors.purple, fontWeight: FontWeight.w900)),

    // TODO: toevoegen input veld dat op basis van de input een suggestie doet uit de lijst met films
                  DropdownButton<Film>(
                    value: _selectedFilm,
                    items: _dropDownFilmItems,
                    onChanged: (value)
                    {
                      setState(()
                      {
                        _selectedFilm= value;
                      });
                    },
                  ),
                ],
              ),
              Row(
            children: <Widget>[
              Icon(Icons.timelapse),
              Text(' Time Table ',
                  style: TextStyle(
                      color: Colors.purple, fontWeight: FontWeight.w900)),
            ],
          ),
              Row(
                children: [
                  Text('thu ',
                      style: TextStyle(
                          fontFamily: 'Courier', fontWeight: FontWeight.w900)),
                  _buildInputfield(1,1),
                  _buildInputfield(1,2),
                  _buildInputfield(1,3),
                  _buildInputfield(1,4),
                  _buildInputfield(1,5),
                ],
              ),
              Row(
                children: [
                  Text('fri ',
                      style: TextStyle(
                          fontFamily: 'Courier', fontWeight: FontWeight.w900)),
                  _buildInputfield(2,1),
                  _buildInputfield(2,2),
                  _buildInputfield(2,3),
                  _buildInputfield(2,4),
                  _buildInputfield(2,5),
                ],
              ),
              Row(
                children: [
                  Text('sat ',
                      style: TextStyle(
                          fontFamily: 'Courier', fontWeight: FontWeight.w900)),
                  _buildInputfield(3,1),
                  _buildInputfield(3,2),
                  _buildInputfield(3,3),
                  _buildInputfield(3,4),
                  _buildInputfield(3,5),
                ],
              ),
              Row(
                children: [
                  Text('sun ',
                      style: TextStyle(
                           fontFamily: 'Courier', fontWeight: FontWeight.w900)),
                  _buildInputfield(4,1),
                  _buildInputfield(4,2),
                  _buildInputfield(4,3),
                  _buildInputfield(4,4),
                  _buildInputfield(4,5),
                ],
              ),
              Row(
                children: [
                  Text('mon ',
                      style: TextStyle(
                          fontFamily: 'Courier', fontWeight: FontWeight.w900)),
                  _buildInputfield(5,1),
                  _buildInputfield(5,2),
                  _buildInputfield(5,3),
                  _buildInputfield(5,4),
                  _buildInputfield(5,5),
                ],
              ),
              Row(
                children: [
                  Text('tue ',
                      style: TextStyle(
                          fontFamily: 'Courier', fontWeight: FontWeight.w900)),
                  _buildInputfield(6,1),
                  _buildInputfield(6,2),
                  _buildInputfield(6,3),
                  _buildInputfield(6,4),
                  _buildInputfield(6,5),
                ],
              ),
              Row(
                children: [
                  Text('wed ',
                      style: TextStyle(
                          fontFamily: 'Courier', fontWeight: FontWeight.w900)),
                  _buildInputfield(7,1),
                  _buildInputfield(7,2),
                  _buildInputfield(7,3),
                  _buildInputfield(7,4),
                  _buildInputfield(7,5),
                ],
              ),
              Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[


              Container(
                margin: EdgeInsets.all(10.0),
                child: FloatingActionButton.extended(
                  heroTag: "Save",
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.black,
                  onPressed: () {
                    saveToDatabase();
                  },
                  icon: Icon(Icons.add),
                  label: Text('Submit'),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: FloatingActionButton.extended(
                  heroTag: "Clear",
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.black,
                  onPressed: () {
                    clearAllFields();
                  },
                  icon: Icon(Icons.delete),
                  label: Text('Clear'),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: FloatingActionButton.extended(
                  heroTag: "Copy",
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  backgroundColor: Colors.lightGreen,
                  foregroundColor: Colors.black,
                  onPressed: () {
                    copyFields();
                  },
                  icon: Icon(Icons.copy),
                  label: Text('Copy'),
                ),
              )

            ],
          ),
        ],
      ),
     ),
    );
  }
}

List<City> parseCities (String responseBody) {
   final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
   return parsed.map<City>((json) => City.fromJason(json)).toList();
}

List<Film> parseFilms (String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Film>((json) => Film.fromJason(json)).toList();
}

List<Cinema> parseCinemas (String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Cinema>((json) => Cinema.fromJason(json)).toList();
}

Future<List<City>> getCities(String country) async {
  final response = await http.post("http://hyperleap.biz/internships2021/Reinout/DB/cities.php", body: {
     "countryCode": country
  });
  return parseCities(response.body);
}

Future<List<Film>> getFilms() async {
  final response = await http.post("http://hyperleap.biz/internships2021/Reinout/DB/films.php", body: {
  });
  return parseFilms(response.body);
}

Future<List<Cinema>> getCinemas(String _stadID) async {
  final response = await http.post("http://hyperleap.biz/internships2021/Reinout/DB/cinemas.php?stadID=" , body: {
      "stadID": _stadID
  });
  return parseCinemas(response.body);
}

Future<bool> insertPlanning(Planning _planning) async {
  if (_planning.planningID == null) {
    final response = await http.post(
        "http://hyperleap.biz/internships2021/Reinout/DB/insertplanning.php",
        body: {
          "filmID": _planning.filmID,
          "cinemaID": _planning.cinemaID,
          "dtBegin": _planning.dtBegin.toString()
        });
  }
  else
  {
     //TODO PHP get  voor bestaande planning and PUT commando voor update

  }
  // TODO: bevestiging naar gebruiker bij succes
  // TODO: response bij fouten ophalen en afhandelen
  return true;
}


