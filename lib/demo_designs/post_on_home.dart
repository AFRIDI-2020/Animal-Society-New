import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pet_lover/fade_animation.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PostsOnHome extends StatefulWidget {
  int index;
  String postId;
  String userProfileImage;
  String username;
  String mobile;
  String petId;
  String photo;
  String video;
  String petName;
  String color;
  String age;
  String gender;
  String genus;
  String totalComments;
  String totalFollowings;
  String totalShares;
  String date;
  String groupId;
  String status;
  PostsOnHome(
      {required this.index,
      required this.postId,
      required this.userProfileImage,
      required this.username,
      required this.mobile,
      required this.petId,
      required this.photo,
      required this.video,
      required this.petName,
      required this.color,
      required this.age,
      required this.gender,
      required this.genus,
      required this.totalComments,
      required this.totalFollowings,
      required this.totalShares,
      required this.date,
      required this.groupId,
      required this.status});

  @override
  _PostsOnHomeState createState() => _PostsOnHomeState();
}

class _PostsOnHomeState extends State<PostsOnHome> {
  bool _isFollowed = false;
  String? _currentMobileNo;
  String? _username;
  String? _currentImage;
  int count = 0;

  String _groupName = '';

  VideoPlayerController? controller;

  bool isVisible = true;

  Widget? videoStatusAnimation;

  Future<void> _customInit(
      UserProvider userProvider, AnimalProvider animalProvider) async {
    if (mounted) {
      setState(() {
        count++;
      });
    }

    await userProvider.getCurrentUserInfo().then((value) {
      Map userInfo = userProvider.currentUserMap;
      _currentMobileNo = userInfo['mobileNo'];
      _username = userInfo['username'];
      _currentImage = userInfo['profileImageLink'];
    });

    await FirebaseFirestore.instance
        .collection('Groups')
        .doc(widget.groupId)
        .get()
        .then((value) {
      setState(() {
        _groupName = value['groupName'];
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
            backgroundImage: widget.userProfileImage == ''
                ? AssetImage('assets/profile_image_demo.png')
                : NetworkImage(widget.userProfileImage) as ImageProvider,
            radius: size.width * .05,
          ),
          trailing: Icon(Icons.more_vert),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(
                  widget.username,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: size.width * .04,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  ' posted on ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * .04,
                  ),
                ),
                Text(
                  _groupName,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: size.width * .04,
                      fontWeight: FontWeight.bold),
                ),
              ]),
              SizedBox(height: size.width * .01),
              Text(
                widget.date,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * .035,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: size.width * .02,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.status,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
        Visibility(
          visible: widget.photo.isNotEmpty || widget.video.isNotEmpty,
          child: Container(
              width: size.width,
              height: size.width * .7,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300)),
              child: widget.photo != ''
                  ? Center(
                      child: Image.network(
                      widget.photo,
                      fit: BoxFit.fill,
                    ))
                  : Center(
                      child: controller!.value.isInitialized
                          ? Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: controller!.value.aspectRatio,
                                  child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isVisible = !isVisible;
                                        });

                                        if (!controller!.value.isInitialized) {
                                          return;
                                        }
                                        if (controller!.value.isPlaying) {
                                          videoStatusAnimation = FadeAnimation(
                                              child: const Icon(Icons.pause,
                                                  size: 100.0));
                                          controller!.pause();
                                        } else {
                                          videoStatusAnimation = FadeAnimation(
                                              child: const Icon(
                                                  Icons.play_arrow,
                                                  size: 100.0));
                                          controller!.play();
                                        }
                                      },
                                      child: VideoPlayer(controller!)),
                                ),
                                Positioned.fill(
                                    child: Stack(
                                  children: <Widget>[
                                    Center(child: videoStatusAnimation),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: buildIndicator(),
                                    ),
                                  ],
                                ))
                              ],
                            )
                          : CircularProgressIndicator(),
                    )),
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: size.width * .02),
              child: Text(
                widget.totalFollowings,
                style:
                    TextStyle(color: Colors.black, fontSize: size.width * .038),
              ),
            ),
            InkWell(
              onTap: () {},
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
                widget.totalComments,
                style:
                    TextStyle(color: Colors.black, fontSize: size.width * .038),
              ),
            ),
            InkWell(
              onTap: () {},
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
                widget.totalShares,
                style:
                    TextStyle(color: Colors.black, fontSize: size.width * .038),
              ),
            ),
            InkWell(
              onTap: () {
                showAlertDialog(context, widget.petId, animalProvider);
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
              Visibility(
                visible: widget.petName == '' ? false : true,
                child: Row(
                  children: [
                    Text('Pet name: ',
                        style: TextStyle(
                            color: Colors.black, fontSize: size.width * .038)),
                    Text(widget.petName,
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: size.width * .038)),
                  ],
                ),
              ),
              Visibility(
                visible: widget.color == '' ? false : true,
                child: Row(
                  children: [
                    Text('Color: ',
                        style: TextStyle(
                            color: Colors.black, fontSize: size.width * .038)),
                    Text(widget.color,
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: size.width * .038)),
                  ],
                ),
              ),
              Visibility(
                visible: widget.genus == '' ? false : true,
                child: Row(
                  children: [
                    Text('Genus: ',
                        style: TextStyle(
                            color: Colors.black, fontSize: size.width * .038)),
                    Text(widget.genus,
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: size.width * .038)),
                  ],
                ),
              ),
              Visibility(
                visible: widget.gender == '' ? false : true,
                child: Row(
                  children: [
                    Text('Gender: ',
                        style: TextStyle(
                            color: Colors.black, fontSize: size.width * .038)),
                    Text(widget.gender,
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: size.width * .038)),
                  ],
                ),
              ),
              Visibility(
                visible: widget.age == '' ? false : true,
                child: Row(
                  children: [
                    Text('Age: ',
                        style: TextStyle(
                            color: Colors.black, fontSize: size.width * .038)),
                    Text(widget.age,
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
            backgroundImage: AssetImage('assets/profile_image_demo.png'),
            // backgroundImage: _currentImage == ''
            //     ? AssetImage('assets/profile_image_demo.png')
            //     : NetworkImage(_currentImage!) as ImageProvider,
            radius: size.width * .04,
          ),
          onTap: () {},
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

  Widget buildIndicator() => VideoProgressIndicator(
        controller!,
        allowScrubbing: true,
      );

  showAlertDialog(
      BuildContext context, String petId, AnimalProvider animalProvider) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () async {},
    );

    AlertDialog alert = AlertDialog(
      title: Text("Share animal"),
      content: Text("Do you want to share ${widget.petName}?"),
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
}
