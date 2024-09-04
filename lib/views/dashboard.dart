// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sort_child_properties_last

import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:systat/components/edit_uri.dart';
import 'package:systat/database/database.dart';
import 'package:systat/models/stat.dart';
import 'package:systat/services/remote_service.dart';
import 'package:systat/views/fetcherror.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final limitcount = 6;
  final mempoints = <FlSpot>[];
  final diskpoints = <FlSpot>[];
  Stat? stats;
  var isloaded = false;
  Timer? timer;
  double xValue = 0;
  int delaytime = 1;

  final _database = Hive.box('staturi');
  sysstatdb db = sysstatdb();
  @override
  void initState() {
    super.initState();
    if (_database.get("url") == null) {
      db.create_init_uri();
    } else {
      db.load_uri();
    }

    try {
      _loadStats();
    } catch (e) {
      errPage();
    }

    mempoints.add(FlSpot(0, 0));
    diskpoints.add(FlSpot(0, 0));
    mempoints.add(FlSpot(0, 0));
    diskpoints.add(FlSpot(0, 0));

    xValue += 1;
    try {
      timer = Timer.periodic(Duration(seconds: delaytime), (timer) async {
        stats = await RemoteService().getStats(db.url);
        while (mempoints.length > limitcount + 1) {
          mempoints.removeAt(0);
          diskpoints.removeAt(0);
        }
        setState(() {
          isloaded = true;
          try {
            mempoints
                .add(FlSpot(xValue, (stats!.memoryUsage.usedMb).toDouble()));
            diskpoints
                .add(FlSpot(xValue, (stats!.diskUsage.usedMb).toDouble()));
          } catch (e) {
            errPage();
          }
        });
        xValue += 1;
      });
    } catch (e) {
      errPage();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  _loadStats() async {
    // API call to load stats
    stats = await RemoteService().getStats(db.url);
    if (stats == null) {
      errPage();
    }

    setState(() {
      isloaded = true;
    });
  }

  void editUri() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditUriDialog(
          onConfirm: (url) {
            setState(() {
              db.url = url;
              db.update_uri();
              _loadStats();
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => editUri(),
        child: Icon(Icons.edit_square),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      appBar: AppBar(
        title: Text(
          'SysStat',
          style: TextStyle(fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: Visibility(
            visible: isloaded,
            child: ListView(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  margin:
                      EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                  child: AspectRatio(
                    aspectRatio: 3.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CPU Usage',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            Text(
                              '${stats?.cpuUsagePercentage}%',
                              style: TextStyle(
                                  fontSize: 20.sp, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: PieChart(PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: (stats?.cpuUsagePercentage),
                                color: Colors.red,
                                radius: 20.sp,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: (stats?.cpuUsagePercentage == 0)
                                    ? (100 - (stats!.cpuUsagePercentage))
                                    : 100,
                                radius: 20.sp,
                                color: Colors.grey,
                                showTitle: false,
                              ),
                            ],
                          )),
                        )
                      ],
                    ),
                  ),
                ),

                //Memory

                Container(
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.sp),
                      color: Color.fromARGB(255, 18, 38, 48),
                    ),
                    margin:
                        EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Memory Usage',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                Text(
                                  '${stats?.memoryUsage.usePercent}%',
                                  style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total: ${stats?.memoryUsage.totalMb} MB',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                Text(
                                  'Used: ${stats?.memoryUsage.usedMb} MB',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                Text(
                                  'Free: ${stats?.memoryUsage.freeMb} MB',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        AspectRatio(
                          aspectRatio: 2.0,
                          child: LineChart(
                            duration: Duration(seconds: delaytime),
                            LineChartData(
                                clipData: FlClipData.horizontal(),
                                gridData: FlGridData(
                                  show: false,
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                maxY: (stats?.memoryUsage.totalMb)?.toDouble(),
                                minY: 0,
                                minX: mempoints[1].x,
                                maxX: mempoints.last.x,
                                titlesData: FlTitlesData(
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    )),
                                lineBarsData: [memLine(mempoints)]),
                          ),
                          // Optional
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                      ],
                    )),

                //disk

                Container(
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.sp),
                      color: Color.fromARGB(255, 18, 38, 48),
                    ),
                    margin:
                        EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Disk Usage',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                Text(
                                  '${stats?.diskUsage.usePercent}%',
                                  style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total: ${stats?.diskUsage.totalMb} MB',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                Text(
                                  'Used: ${stats?.diskUsage.usedMb} MB',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                Text(
                                  'Free: ${stats?.diskUsage.freeMb} MB',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        AspectRatio(
                          aspectRatio: 2.0,
                          child: LineChart(
                            duration: Duration(seconds: delaytime),
                            LineChartData(
                                clipData: FlClipData.horizontal(),
                                gridData: FlGridData(
                                  show: false,
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                maxY: (stats?.diskUsage.totalMb)?.toDouble(),
                                minY: 0,
                                minX: diskpoints[1].x,
                                maxX: diskpoints.last.x,
                                titlesData: FlTitlesData(
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    )),
                                lineBarsData: [memLine(diskpoints)]),
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                      ],
                    )),
              ],
            )),
      ),
    );
  }
}

LineChartBarData memLine(List<FlSpot> points) {
  return LineChartBarData(
      spots: points,
      isStrokeCapRound: true,
      gradient: LinearGradient(colors: [
        Colors.red,
        Colors.yellow,
        Colors.green,
      ]),
      dotData: const FlDotData(
        show: true,
      ),
      barWidth: 2,
      isCurved: true,
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [Colors.blueAccent.withOpacity(0.5), Colors.transparent],
          stops: const [0.25, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ));
}
