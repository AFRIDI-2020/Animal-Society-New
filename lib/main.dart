import 'package:flutter/material.dart';
import 'package:pet_lover/home.dart';
import 'package:pet_lover/login.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/groupProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final _prefs = await SharedPreferences.getInstance();
  String? _currentMobileNo = _prefs.getString('mobileNo') ?? null;
  runApp(MyApp(currentMobileNo: _currentMobileNo));
}

class MyApp extends StatelessWidget {
  String? currentMobileNo;
  MyApp({required this.currentMobileNo});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.grey.shade100,
        statusBarIconBrightness: Brightness.dark));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnimalProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider())
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          backgroundColor: Colors.black,
          primarySwatch: Colors.deepOrange,
        ),
        home: currentMobileNo == null ? Login() : Home(),
      ),
    );
  }
}
