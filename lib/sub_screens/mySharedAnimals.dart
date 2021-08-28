import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_lover/demo_designs/mySharedAnimalsDemo.dart';
import 'package:pet_lover/demo_designs/my_animals_demo.dart';
import 'package:pet_lover/model/animal.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:provider/provider.dart';

class MySharedAnimals extends StatefulWidget {
  const MySharedAnimals({Key? key}) : super(key: key);

  @override
  _MySharedAnimalsState createState() => _MySharedAnimalsState();
}

class _MySharedAnimalsState extends State<MySharedAnimals> {
  int _count = 0;
  bool _loading = false;
  List<Animal> _sharedAnimalList = [];
  Map<String, String> _currentUserInfoMap = {};
  String _userMobileNo = '';
  String? finalDate;

  Future _customInit(
      AnimalProvider animalProvider, UserProvider userProvider) async {
    setState(() {
      _count++;
      _loading = true;
    });

    await userProvider.getCurrentUserInfo().then((value) {
      _currentUserInfoMap = userProvider.currentUserMap;
      _userMobileNo = _currentUserInfoMap['mobileNo']!;
      print('shared animals owner mobile no = $_userMobileNo');
    });

    await animalProvider.getUserSharedAnimals(_userMobileNo).then((value) {
      setState(() {
        _loading = false;
      });
      print(
          'total shared animals = ${animalProvider.userSharedAnimals.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Your Shared Animals',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
      ),
      body: _bodyUI(context),
    );
  }

  Widget _bodyUI(BuildContext context) {
    final AnimalProvider animalProvider = Provider.of<AnimalProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    Size size = MediaQuery.of(context).size;
    if (_count == 0) _customInit(animalProvider, userProvider);

    return _loading
        ? Center(child: CircularProgressIndicator())
        : animalProvider.userSharedAnimals.isEmpty
            ? Center(
                child: Text(
                  'Nothing has been shared yet!',
                  style: TextStyle(fontSize: size.width * .04),
                ),
              )
            : ListView.builder(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: animalProvider.userSharedAnimals.length,
                itemBuilder: (context, index) {
                  DateTime miliDate = new DateTime.fromMillisecondsSinceEpoch(
                      int.parse(animalProvider.userSharedAnimals[index].date!));
                  var format = new DateFormat("yMMMd").add_jm();
                  finalDate = format.format(miliDate);
                  return MySharedAnimalsDemo(
                      index: index,
                      profileImageLink: animalProvider
                          .userSharedAnimals[index].userProfileImage!,
                      username:
                          animalProvider.userSharedAnimals[index].username!,
                      mobile: animalProvider.userSharedAnimals[index].mobile!,
                      date: finalDate!,
                      numberOfLoveReacts: animalProvider
                          .userSharedAnimals[index].totalFollowings!,
                      numberOfComments: animalProvider
                          .userSharedAnimals[index].totalComments!,
                      numberOfShares:
                          animalProvider.userSharedAnimals[index].totalShares!,
                      petId: animalProvider.userSharedAnimals[index].id!,
                      petName: animalProvider.userSharedAnimals[index].petName!,
                      petColor: animalProvider.userSharedAnimals[index].color!,
                      petGenus: animalProvider.userSharedAnimals[index].genus!,
                      petGender:
                          animalProvider.userSharedAnimals[index].gender!,
                      petAge: animalProvider.userSharedAnimals[index].age!,
                      petImage: animalProvider.userSharedAnimals[index].photo!,
                      petVideo: animalProvider.userSharedAnimals[index].video!,
                      currentUserImage:
                          _currentUserInfoMap['profileImageLink']!);
                });
  }
}
