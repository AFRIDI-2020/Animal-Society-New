import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_lover/demo_designs/animal_post.dart';
import 'package:pet_lover/model/animal.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:provider/provider.dart';

class UserAnimals extends StatefulWidget {
  String userMobileNo;
  String username;
  UserAnimals({Key? key, required this.userMobileNo, required this.username})
      : super(key: key);

  @override
  _UserAnimalsState createState() => _UserAnimalsState(userMobileNo, username);
}

class _UserAnimalsState extends State<UserAnimals> {
  String userMobileNo;
  String username;
  _UserAnimalsState(this.userMobileNo, this.username);
  int _count = 0;
  List<Animal> _otherUserAnimals = [];
  Map<String, String> _currentUserInfoMap = {};
  String? finalDate;

  Future _customInit(
      AnimalProvider animalProvider, UserProvider userProvider) async {
    setState(() {
      _count++;
    });
    await userProvider.getCurrentUserInfo().then((value) {
      _currentUserInfoMap = userProvider.currentUserMap;
    });
    await animalProvider.getOtherUserAnimals(userMobileNo).then((value) {
      setState(() {
        _otherUserAnimals = animalProvider.otheUserAnimals;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Animals of $username',
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
    if (_count == 0) _customInit(animalProvider, userProvider);
    return _otherUserAnimals.length == 0
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: _otherUserAnimals.length,
            itemBuilder: (context, index) {
              DateTime miliDate = new DateTime.fromMillisecondsSinceEpoch(
                  int.parse(_otherUserAnimals[index].date!));
              var format = new DateFormat("yMMMd").add_jm();
              finalDate = format.format(miliDate);
              return AnimalPost(
                  index: index,
                  status: _otherUserAnimals[index].status!,
                  groupId: _otherUserAnimals[index].groupId!,
                  profileImageLink: _otherUserAnimals[index].userProfileImage!,
                  username: _otherUserAnimals[index].username!,
                  mobile: _otherUserAnimals[index].mobile!,
                  date: finalDate!,
                  numberOfLoveReacts: _otherUserAnimals[index].totalFollowings!,
                  numberOfComments: _otherUserAnimals[index].totalComments!,
                  numberOfShares: _otherUserAnimals[index].totalShares!,
                  petId: _otherUserAnimals[index].id!,
                  petName: _otherUserAnimals[index].petName!,
                  petColor: _otherUserAnimals[index].color!,
                  petGenus: _otherUserAnimals[index].genus!,
                  petGender: _otherUserAnimals[index].gender!,
                  petAge: _otherUserAnimals[index].age!,
                  petImage: _otherUserAnimals[index].photo!,
                  petVideo: _otherUserAnimals[index].video!,
                  currentUserImage: _currentUserInfoMap['profileImageLink']!);
            });
  }
}
