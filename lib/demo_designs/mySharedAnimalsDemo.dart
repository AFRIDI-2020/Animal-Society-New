import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pet_lover/model/my_animals_menu_item.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/addAnimal.dart';
import 'package:pet_lover/sub_screens/commentSection.dart';
import 'package:provider/provider.dart';

import 'my_animals_menu_item_demo.dart';

class MySharedAnimalsDemo extends StatefulWidget {
  int index;
  String profileImageLink;
  String username;
  String mobile;
  String date;
  String numberOfLoveReacts;
  String numberOfComments;
  String numberOfShares;
  String petId;
  String petName;
  String petColor;
  String petGenus;
  String petGender;
  String petAge;
  String petImage;
  String petVideo;
  String currentUserImage;
  MySharedAnimalsDemo(
      {Key? key,
      required this.index,
      required this.profileImageLink,
      required this.username,
      required this.mobile,
      required this.date,
      required this.numberOfLoveReacts,
      required this.numberOfComments,
      required this.numberOfShares,
      required this.petId,
      required this.petName,
      required this.petColor,
      required this.petGenus,
      required this.petGender,
      required this.petAge,
      required this.petImage,
      required this.petVideo,
      required this.currentUserImage})
      : super(key: key);

  @override
  _MySharedAnimalsDemoState createState() => _MySharedAnimalsDemoState(
      index,
      profileImageLink,
      username,
      mobile,
      date,
      numberOfLoveReacts,
      numberOfComments,
      numberOfShares,
      petId,
      petName,
      petColor,
      petGenus,
      petGender,
      petAge,
      petImage,
      petVideo,
      currentUserImage);
}

class _MySharedAnimalsDemoState extends State<MySharedAnimalsDemo> {
  int index;
  String profileImageLink;
  String username;
  String mobile;
  String date;
  String numberOfLoveReacts;
  String numberOfComments;
  String numberOfShares;
  String petId;
  String petName;
  String petColor;
  String petGenus;
  String petGender;
  String petAge;
  String petImage;
  String petVideo;
  String currentUserImage;
  _MySharedAnimalsDemoState(
      this.index,
      this.profileImageLink,
      this.username,
      this.mobile,
      this.date,
      this.numberOfLoveReacts,
      this.numberOfComments,
      this.numberOfShares,
      this.petId,
      this.petName,
      this.petColor,
      this.petGenus,
      this.petGender,
      this.petAge,
      this.petImage,
      this.petVideo,
      this.currentUserImage);

  bool _isFollowed = false;
  String? _currentMobileNo;
  String? _username;
  String? _currentImage;
  int count = 0;
  int _numberOfFollowers = 0;
  int _numberOfComments = 0;
  int _numberOfShares = 0;

  Future<void> _customInit(
      UserProvider userProvider, AnimalProvider animalProvider) async {
    setState(() {
      count = 1;
    });

    await userProvider.getCurrentUserInfo().then((value) {
      Map userInfo = userProvider.currentUserMap;
      _currentMobileNo = userInfo['mobileNo'];
      _username = userInfo['username'];
      _currentImage = userInfo['profileImageLink'];
    });

    // _getCommentsNumber(animalProvider, petId);
    _getFollowersNumber(animalProvider, petId);
    // _getSharesNumber(animalProvider, petId);
    _isFollowerOrNot(animalProvider, _currentMobileNo!);
  }

  _addAnimalOwnerInMyFollowings(
      AnimalProvider animalProvider,
      String currentMobileNo,
      String mobileNo,
      String followingName,
      String followerName,
      String followingImage,
      String followerImage,
      UserProvider userProvider) async {
    await animalProvider.myFollowings(currentMobileNo, mobileNo, followingName,
        followerName, followingImage, followerImage, userProvider);
  }

  _isFollowerOrNot(
      AnimalProvider animalProvider, String currentMobileNo) async {
    await animalProvider.isFollowerOrNot(petId, currentMobileNo).then((value) {
      _isFollowed = animalProvider.isFollower;
    });
  }

  _getFollowersNumber(AnimalProvider animalProvider, String _animalId) async {
    await animalProvider.getNumberOfFollowers(_animalId).then((value) {
      setState(() {
        _numberOfFollowers = animalProvider.numberOfFollowers;
      });
      print('$petId has $_numberOfFollowers followers');
    });
  }

  _getSharesNumber(AnimalProvider animalProvider, String _animalId) async {
    await animalProvider.getNumberOfShares(_animalId).then((value) {
      setState(() {
        _numberOfShares = animalProvider.numberOfShares;
      });
      print('$petId has $numberOfShares shares');
    });
  }

  _getCommentsNumber(AnimalProvider animalProvider, String _animalId) async {
    await animalProvider.getNumberOfComments(_animalId).then((value) {
      setState(() {
        _numberOfComments = animalProvider.numberOfComments;
      });
      print('$petId has $_numberOfComments comments');
    });
  }

  _showDeleteToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('$petName has been deleted successfully.'),
      ),
    );
  }

  _deleteAnimal(AnimalProvider animalProvider) async {
    await animalProvider.deleteAnimal(petId, petImage).then((value) {
      setState(() {
        _showDeleteToast(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final AnimalProvider animalProvider = Provider.of<AnimalProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    if (count == 0) _customInit(userProvider, animalProvider);

    Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      child: Column(children: [
        SizedBox(
          height: size.width * .04,
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: profileImageLink == ''
                ? AssetImage('assets/profile_image_demo.png')
                : NetworkImage(profileImageLink) as ImageProvider,
            radius: size.width * .05,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * .035,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                date,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * .035,
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton<MyAnimalItemMenu>(
              onSelected: (item) =>
                  onSelectedMenuItem(context, item, animalProvider),
              itemBuilder: (context) =>
                  [...MyAnimalsMenu.MyAnimalsMenuList.map(buildItem).toList()]),
        ),
        SizedBox(
          height: size.width * .02,
        ),
        Container(
            width: size.width,
            height: size.width * .7,
            decoration:
                BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
            child: Center(
                child: Image.network(
              petImage,
              fit: BoxFit.fill,
            ))),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: size.width * .02),
              child: Text(
                _numberOfFollowers.toString(),
                style:
                    TextStyle(color: Colors.black, fontSize: size.width * .038),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _isFollowed = !_isFollowed;

                  if (_isFollowed == true) {
                    animalProvider.addFollowers(
                        petId, _currentMobileNo!, _username!);
                    _getFollowersNumber(animalProvider, petId);
                    _addAnimalOwnerInMyFollowings(
                        animalProvider,
                        _currentMobileNo!,
                        mobile,
                        widget.username,
                        _username!,
                        widget.profileImageLink,
                        _currentImage!,
                        userProvider);
                  }
                  if (_isFollowed == false) {
                    _getFollowersNumber(animalProvider, petId);
                  }
                });
              },
              child: Padding(
                padding: EdgeInsets.all(size.width * .02),
                child: _isFollowed == false
                    ? Icon(
                        FontAwesomeIcons.heart,
                        size: size.width * .06,
                        color: Colors.black,
                      )
                    : Icon(
                        FontAwesomeIcons.solidHeart,
                        size: size.width * .06,
                        color: Colors.red,
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width * .04),
              child: Text(
                animalProvider.animalList[index].totalComments,
                style:
                    TextStyle(color: Colors.black, fontSize: size.width * .038),
              ),
            ),
            InkWell(
              onTap: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => CommetPage(
                //               id: petId,
                //               animalOwnerMobileNo: mobile,
                //               index: index,
                //             )));
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(size.width * .02, size.width * .02,
                    size.width * .02, size.width * .02),
                child: Icon(
                  FontAwesomeIcons.comment,
                  color: Colors.black,
                  size: size.width * .06,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width * .04),
              child: Text(
                animalProvider.animalList[index].totalShares,
                style:
                    TextStyle(color: Colors.black, fontSize: size.width * .038),
              ),
            ),
            InkWell(
              onTap: () {
                showAlertDialog(context, petId, animalProvider);
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(size.width * .02, size.width * .02,
                    size.width * .02, size.width * .02),
                child: Icon(
                  Icons.share,
                  color: Colors.black,
                  size: size.width * .06,
                ),
              ),
            )
          ],
        ),
        Container(
            width: size.width,
            padding: EdgeInsets.fromLTRB(size.width * .02, size.width * .01,
                size.width * .02, size.width * .01),
            child: Column(children: [
              Row(
                children: [
                  Text('Pet name: ',
                      style: TextStyle(
                          color: Colors.black, fontSize: size.width * .038)),
                  Text(petName,
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: size.width * .038)),
                ],
              ),
              Visibility(
                visible: petColor == '' ? false : true,
                child: Row(
                  children: [
                    Text('Color: ',
                        style: TextStyle(
                            color: Colors.black, fontSize: size.width * .038)),
                    Text(petColor,
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: size.width * .038)),
                  ],
                ),
              ),
              Visibility(
                visible: petGenus == '' ? false : true,
                child: Row(
                  children: [
                    Text('Genus: ',
                        style: TextStyle(
                            color: Colors.black, fontSize: size.width * .038)),
                    Text(petGenus,
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: size.width * .038)),
                  ],
                ),
              ),
              Visibility(
                visible: petGender == '' ? false : true,
                child: Row(
                  children: [
                    Text('Gender: ',
                        style: TextStyle(
                            color: Colors.black, fontSize: size.width * .038)),
                    Text(petGender,
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: size.width * .038)),
                  ],
                ),
              ),
              Visibility(
                visible: petAge == '' ? false : true,
                child: Row(
                  children: [
                    Text('Age: ',
                        style: TextStyle(
                            color: Colors.black, fontSize: size.width * .038)),
                    Text(petAge,
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: size.width * .038)),
                  ],
                ),
              )
            ])),
        ListTile(
          title: Text(
            'Add comment...',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: currentUserImage == ''
                ? AssetImage('assets/profile_image_demo.png')
                : NetworkImage(currentUserImage) as ImageProvider,
            radius: size.width * .04,
          ),
          onTap: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => CommetPage(
            //               id: petId,
            //               animalOwnerMobileNo: mobile,
            //             )));
          },
        ),
        Container(
          padding:
              EdgeInsets.fromLTRB(size.width * .02, 0, size.width * .02, 0),
          child: Divider(
            color: Colors.grey.shade300,
            height: size.width * .002,
          ),
        ),
      ]),
    );
  }

  showAlertDialog(
      BuildContext context, String petId, AnimalProvider animalProvider) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Share"),
      onPressed: () async {
        await animalProvider.shareAnimal(petId).then((value) async {
          setState(() {
            _getSharesNumber(animalProvider, petId);
          });
          Navigator.pop(context);
          _showToast(context);
        });
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Share animal"),
      content: Text("Do you want to share $petName?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Animal shared successfully.'),
      ),
    );
  }

  PopupMenuItem<MyAnimalItemMenu> buildItem(MyAnimalItemMenu item) =>
      PopupMenuItem<MyAnimalItemMenu>(
          value: item,
          child: Row(
            children: [
              Icon(item.iconData),
              SizedBox(
                width: 10,
              ),
              Text(item.text)
            ],
          ));

  onSelectedMenuItem(BuildContext context, MyAnimalItemMenu item,
      AnimalProvider animalProvider) {
    switch (item) {
      case MyAnimalsMenu.editAnimalPost:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddAnimal(petId: petId)));
        break;
      case MyAnimalsMenu.deleteAnimalPost:
        // _deleteAnimal(animalProvider);
        break;
    }
  }
}
