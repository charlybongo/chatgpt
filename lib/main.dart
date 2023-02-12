import 'package:chatgpt/pages/landingPage/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MaterialApp(home: LandingPage())));
}
