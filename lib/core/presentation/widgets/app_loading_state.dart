import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A centered loading indicator used when pages / sections are loading.
class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 40.w,
        height: 40.w,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
