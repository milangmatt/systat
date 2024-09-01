import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:systat/models/stat.dart';
import 'package:systat/services/remote_service.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final limitcount = 10;
  final mempoints = <FlSpot>[];
  final diskpoints = <FlSpot>[];
  Stat? stats;
  var isloaded = false;
  Timer? timer;
  double xValue = 0;
  int delaytime = 1;

  @override
  void initState() {
    super.initState();
    _loadStats();
    mempoints.add(FlSpot(0, 0));
    diskpoints.add(FlSpot(0, 0));
    xValue += 1;
    timer = Timer.periodic(Duration(seconds: delaytime), (timer) async {
      stats = await RemoteService().getStats();
      while (mempoints.length > limitcount + 1) {
        mempoints.removeAt(0);
        diskpoints.removeAt(0);
      }
      setState(() {
        isloaded = true;
        mempoints.add(FlSpot(xValue, (stats!.memoryUsage.usedMb).toDouble()));
        diskpoints.add(FlSpot(xValue, (stats!.diskUsage.usedMb).toDouble()));
      });
      xValue += 1;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  _loadStats() async {
    // API call to load stats
    stats = await RemoteService().getStats();
    setState(() {
      isloaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.dark_mode,
            size: 24.sp,
          ),
          onPressed: () => {},
        ),
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
                    color: Color.fromARGB(255, 18, 38, 48),
                  ),
                  margin:
                      EdgeInsets.symmetric(horizontal: 10.sp, vertical: 5.sp),
                  child: Text(
                    'CPU Usage: ${stats?.cpuUsagePercentage}%',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
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
                        Text(
                          'Memory Usage: ${stats?.memoryUsage.usePercent}%',
                          style: TextStyle(fontSize: 16.sp),
                        ),
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
                        AspectRatio(
                          aspectRatio: 2.0,
                          child: LineChart(
                            duration: Duration(seconds: 1),
                            LineChartData(
                                gridData: FlGridData(
                                  show: false,
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                maxY: (stats?.memoryUsage.totalMb)?.toDouble(),
                                minY: 0,
                                minX: mempoints.first.x,
                                maxX: mempoints.last.x,
                                lineBarsData: [memLine(mempoints)]),
                          ),
                          // Optional
                        )
                      ],
                    )),
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
                        Text(
                          'Disk Usage: ${stats?.diskUsage.usePercent}%',
                          style: TextStyle(fontSize: 16.sp),
                        ),
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
                        AspectRatio(
                          aspectRatio: 2.0,
                          child: LineChart(
                            duration: Duration(seconds: 1),
                            LineChartData(
                                maxY: (stats?.diskUsage.totalMb)?.toDouble(),
                                minY: 0,
                                minX: diskpoints.first.x,
                                maxX: diskpoints.last.x,
                                lineBarsData: [memLine(diskpoints)]),
                          ),
                        )
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
    dotData: const FlDotData(
      show: false,
    ),
    barWidth: 2,
    isCurved: true,
  );
}
