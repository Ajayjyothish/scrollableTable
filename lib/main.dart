import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Report',
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
          headline1: TextStyle(color: Colors.white),
        ),
        primarySwatch: Colors.blue,
      ),
      home: const FitnessReport(title: 'Fitness Report'),
    );
  }
}

class FitnessReport extends StatefulWidget {
  const FitnessReport({super.key, required this.title});
  final String title;

  @override
  State<FitnessReport> createState() => _FitnessReportState();
}

class _FitnessReportState extends State<FitnessReport> {
  final _columnScrollController = ScrollController();
  final _rowScrollController = ScrollController();
  static const _cellWidth = 120.0;
  static const _cellHeight = 50.0;
  late List<String> dates;
  late List<Map<String, dynamic>> exerciseList;

  @override
  void initState() {
    super.initState();
    getPreviousSundays();
    generateExerciseList();
    _rowScrollController.addListener(() {
      if (_rowScrollController.position.pixels != _columnScrollController.position.pixels) {
        _columnScrollController.jumpTo(_rowScrollController.position.pixels);
      }
    });
    _columnScrollController.addListener(() {
      if (_columnScrollController.position.pixels != _rowScrollController.position.pixels) {
        _rowScrollController.jumpTo(_columnScrollController.position.pixels);
      }
    });
  }

  void generateExerciseList() {
    List<Map<String, dynamic>> tempExerciseList = [];

    for (int i = 0; i < dates.length; i++) {
      int running = Random().nextInt(24);
      int jogging = Random().nextInt(24 - running);
      int exercise = Random().nextInt(24 - running - jogging);
      int total = running + jogging + exercise;
      double runPercent = (running / (running + jogging + exercise)) * 100;
      double jogPercent = (jogging / (running + jogging + exercise)) * 100;
      double exercisePercent = (exercise / (running + jogging + exercise)) * 100;

      tempExerciseList.add({'running': running, 'jogging': jogging, 'exercise': exercise, "total": total, "runprecent": "${runPercent.toStringAsFixed(2)}%", "jogPercent": "${jogPercent.toStringAsFixed(2)}%", "exercisePercent": "${exercisePercent.toStringAsFixed(2)}%"});
    }

    setState(() {
      exerciseList = tempExerciseList;
    });
  }

  Map<String, dynamic> calculateTotal() {
    num running = 0, jogging = 0, exercise = 0;
    for (int i = 0; i < dates.length; i++) {
      running += exerciseList[i]['running']!;
      jogging += exerciseList[i]['jogging']!;
      exercise += exerciseList[i]['exercise']!;
    }
    int totalPercent = (running + jogging + exercise).toInt();
    double runningPercent = (running / totalPercent) * 100;
    double joggingPercent = (jogging / totalPercent) * 100;
    double exercisePercent = (exercise / totalPercent) * 100;
    return {
      'running': running.toInt(),
      'jogging': jogging.toInt(),
      'exercise': exercise.toInt(),
      "total": totalPercent,
      'runningPercent': "${runningPercent.toStringAsFixed(2)}%",
      'joggingPercent': "${joggingPercent.toStringAsFixed(2)}%",
      'exercisePercent': "${exercisePercent.toStringAsFixed(2)}%",
    };
  }

  void getPreviousSundays() {
    List<String> previousSundays = [];
    DateFormat df = DateFormat("dd/yy/mm");
    DateTime now = DateTime.now();
    DateTime mostRecentSunday = now.subtract(Duration(days: now.weekday));

    while (mostRecentSunday.isBefore(now)) {
      previousSundays.add(df.format(mostRecentSunday));
      mostRecentSunday = mostRecentSunday.add(const Duration(days: 1));
    }
    previousSundays.add(df.format(now));
    setState(() {
      dates = previousSundays;
    });
  }

  final daysOfweek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  final infoList = ["Running Time", "Jogging Time", "Exercise Time", "Total Time (Running+Jogging+Exercise)", "Running Time engagement % (Running / Total Time)", "Jogging Time engagement % (Jogging / Total Time)", "Exercise Time engagement % (Exercise / Total Time)"];

  renderEmptyCell(double height, double width) {
    return Container(
      alignment: Alignment.center,
      height: height,
      width: width,
      margin: const EdgeInsets.all(4.0),
      child: const Text("", style: TextStyle(fontSize: 15)),
    );
  }

  List<Widget> _renderDateCells(List items, {double height = _cellHeight, double width = _cellWidth}) {
    return List.generate(
      items.length,
      (index) => Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: width,
            height: height,
            margin: const EdgeInsets.all(4.0),
            child: Text("${items[index]}", style: const TextStyle(fontSize: 15)),
          ),
          index < dates.length
              ? Container(
                  alignment: Alignment.center,
                  height: height,
                  width: width,
                  margin: const EdgeInsets.all(4.0),
                  child: Text(dates[index], style: const TextStyle(fontSize: 15)),
                )
              : renderEmptyCell(height, width)
        ],
      ),
    );
  }

  List<Widget> _renderRowCells(List items, {double height = _cellHeight, double width = _cellWidth}) {
    return List.generate(
      items.length,
      (index) => Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 8),
            alignment: Alignment.center,
            width: width,
            height: height,
            margin: const EdgeInsets.all(4.0),
            child: Text("${items[index]}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          renderEmptyCell(height, width)
        ],
      ),
    );
  }

  List<Widget> _renderInfoCells(List items, {double height = _cellHeight, double width = _cellWidth}) {
    final totalMap = calculateTotal();
    return List.generate(
      items.length,
      (index) => Row(children: [
        Container(
          padding: const EdgeInsets.only(left: 8),
          alignment: Alignment.centerLeft,
          height: height,
          width: width + 30,
          margin: const EdgeInsets.all(4.0),
          child: LayoutBuilder(builder: (p0, p1) => Text("${items[index]}", style: TextStyle(fontSize: p1.maxHeight * 0.25, fontWeight: FontWeight.bold))),
        ),
        Container(
          alignment: Alignment.center,
          width: width,
          height: height,
          margin: const EdgeInsets.all(4.0),
          child: Text("${totalMap.values.elementAt(index)}", style: const TextStyle(fontSize: 15)),
        )
      ]),
    );
  }

  List<Widget> _buildCells(int rowIndex, {double height = _cellHeight, double width = _cellWidth}) {
    return List.generate(
        daysOfweek.length,
        (index) => index < exerciseList.length
            ? Container(
                alignment: Alignment.center,
                width: 120.0,
                height: 50.0,
                margin: const EdgeInsets.all(4.0),
                child: Text("${exerciseList[index].values.elementAt(rowIndex)}", style: const TextStyle(fontSize: 15)),
              )
            : renderEmptyCell(height, width));
  }

  List<Widget> _buildRows(int rowcount) {
    return List.generate(
      rowcount,
      (rowIndex) => Row(
        children: _buildCells(rowIndex),
      ),
    );
  }

  BoxDecoration lightPurpleBoxDecoration([BorderRadius? border]) {
    return BoxDecoration(
      borderRadius: border,
      gradient: const LinearGradient(
        colors: [Color.fromARGB(255, 184, 95, 200), Color.fromARGB(255, 132, 100, 186)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  static const purpleBoxDecoration = BoxDecoration(
    borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
    gradient: LinearGradient(
      colors: [Colors.purple, Colors.deepPurple],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const roundedBoxDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(builder: ((context, orientation) {
          if (orientation == Orientation.portrait) {
            Future.delayed(Duration.zero, () {
              if (!Navigator.canPop(context)) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: const Text('Rotate your device'),
                    content: const Text('Please switch to landscape mode for a better experience.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('NO'),
                      ),
                      TextButton(
                        onPressed: () {
                          SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            });
          } else {
            Future.delayed(Duration.zero, () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            });
          }
          return Container(
              margin: const EdgeInsets.all(8),
              decoration: roundedBoxDecoration,
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      // margin: const EdgeInsets.all(8),
                      decoration: lightPurpleBoxDecoration(),
                      clipBehavior: Clip.antiAlias,
                      child: Row(children: [
                        Row(
                          children: [
                            ..._renderRowCells(["Total Info for the week"], width: 150),
                            ..._renderRowCells(["Total (Sun-Sat)"])
                          ],
                        ),
                        Expanded(child: SingleChildScrollView(controller: _columnScrollController, scrollDirection: Axis.horizontal, child: Row(children: _renderDateCells(daysOfweek))))
                      ])),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            // margin: const EdgeInsets.only(left: 8),
                            decoration: lightPurpleBoxDecoration(const BorderRadius.only(bottomLeft: Radius.circular(8))),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _renderInfoCells(infoList),
                            )),
                        Expanded(
                            child: Container(
                          decoration: purpleBoxDecoration,
                          child: SingleChildScrollView(
                            controller: _rowScrollController,
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildRows(infoList.length),
                            ),
                          ),
                        ))
                      ],
                    ),
                  )),
                ],
              ));
        })),
      ),
    );
  }
}
