import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_lover/demo_designs/animal_post.dart';
import 'package:pet_lover/model/animal.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:provider/provider.dart';

class UserSharedAnimals extends StatefulWidget {
  String userMobileNo;
  String username;
  UserSharedAnimals(
      {Key? key, required this.userMobileNo, required this.username})
      : super(key: key);

  @override
  _UserSharedAnimalsState createState() =>
      _UserSharedAnimalsState(userMobileNo, username);
}

class _UserSharedAnimalsState extends State<UserSharedAnimals> {
  String userMobileNo;
  String username;
  _UserSharedAnimalsState(this.userMobileNo, this.username);
  int _count = 0;
  List<Animal> _sharedAnimalList = [];
  Map<String, String> _currentUserInfoMap = {};
  String? finalDate;
  bool _loading = false;

  Future _customInit(
      AnimalProvider animalProvider, UserProvider userProvider) async {
    setState(() {
      _count++;
      _loading = true;
    });

    await userProvider.getCurrentUserInfo().then((value) {
      _currentUserInfoMap = userProvider.currentUserMap;
    });

    await animalProvider.getUserSharedAnimals(userMobileNo).then((value) {
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
          'Shared Animals',
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
                  return AnimalPost(
                      index: index,
                      status: animalProvider.userSharedAnimals[index].status!,
                      groupId: animalProvider.userSharedAnimals[index].groupId!,
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
