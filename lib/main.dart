import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPageScaffold(),
    );
  }
}

class MainPageScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: MainPageDesignColumn(),
      ),
    );
  }
}

class MainPageDesignColumn extends StatefulWidget {
  @override
  _MainPageDesignColumnState createState() => _MainPageDesignColumnState();
}

class _MainPageDesignColumnState extends State<MainPageDesignColumn> {
  var widgetList = <Widget>[];
  var questionArray = <String>[];
  var ansArray = <String>[];
  var unescape = new HtmlUnescape();
  int i = 0;
  String currQuestion = 'Getting Question';

  _MainPageDesignColumnState() {
    this.getQuestions();
  }
  void getQuestions() async {
    var url = 'https://opentdb.com/api.php?amount=10&type=boolean';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      if (jsonResponse['response_code'] == 0) {
        for (int i = 0; i < jsonResponse['results'].length; i++) {
          questionArray
              .add(unescape.convert(jsonResponse['results'][i]['question']));
          ansArray.add(jsonResponse['results'][i]['correct_answer']);
        }
        generateQues();
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void generateIcon(String btnText) {
    setState(() {
      if (i < 10) {
        if (ansArray[i] == btnText) {
          widgetList.add(Icon(
            Icons.check,
            color: Colors.green,
          ));
        } else {
          widgetList.add(Icon(
            Icons.clear,
            color: Colors.red,
          ));
        }
        i += 1;
        generateQues();
      } else {
        showDialog(
          context: context,
          builder: (_) => NetworkGiffyDialog(
            title: Text(
              'Game Over',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
            ),
            image: Image.network(
                "https://raw.githubusercontent.com/Shashank02051997/FancyGifDialog-Android/master/GIF's/gif14.gif"),
            description: Text(
              'All questions completed press "Restart" to start again',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.0),
            ),
            entryAnimation: EntryAnimation.BOTTOM_LEFT,
            onlyOkButton: true,
            buttonOkText: Text(
              'Restart',
              style: TextStyle(color: Colors.white),
            ),
            buttonOkColor: Colors.green,
            onOkButtonPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyApp()));
            },
          ),
        );
      }
    });
  }

  void generateQues() {
    setState(() {
      if (questionArray.isEmpty) {
        currQuestion = 'Getting Question';
      } else {
        if (i < 10) {
          currQuestion = questionArray[i];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 8,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
            child: Center(
              child: Text(
                currQuestion,
                style: TextStyle(color: Colors.white, fontSize: 22.0),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: CreateButton(
            btnText: 'True',
            btnColor: Colors.green,
            generateIcon: generateIcon,
          ),
        ),
        Expanded(
          flex: 2,
          child: CreateButton(
            btnText: 'False',
            btnColor: Colors.red,
            generateIcon: generateIcon,
          ),
        ),
        Expanded(flex: 1, child: ListOfScore(widgetList)),
      ],
    );
  }
}

class CreateButton extends StatelessWidget {
  String btnText;
  Color btnColor;
  Function generateIcon;
  CreateButton(
      {@required this.btnText,
      @required this.btnColor,
      @required this.generateIcon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: btnColor),
        ),
        onPressed: () {
          generateIcon(btnText);
        },
        child: Text(
          btnText,
          style: TextStyle(fontSize: 15.0),
        ),
        color: btnColor,
        textColor: Colors.white,
      ),
    );
  }
}

class ListOfScore extends StatefulWidget {
  var widgetList;
  ListOfScore(@required this.widgetList);
  @override
  _ListOfScoreState createState() => _ListOfScoreState(widgetList);
}

class _ListOfScoreState extends State<ListOfScore> {
  var widgetList;
  _ListOfScoreState(this.widgetList);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgetList,
    );
  }
}
