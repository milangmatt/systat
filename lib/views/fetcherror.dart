// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:systat/main.dart';

class errPage extends StatelessWidget {
  const errPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red[300],
              size: 30.sp,
            ),
            Text(
              "Some error encountered. Try again",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp),
            ),
            ElevatedButton(
              onPressed: () => restartApp,
              style: ButtonStyle(iconSize: WidgetStatePropertyAll(30.sp)),
              child: Text('Try Again'),
            )
          ],
        ),
      ),
    );
  }
}
