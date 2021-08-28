import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pet_lover/custom_classes/toast.dart';
import 'package:pet_lover/demo_designs/comment_edit_delete.dart';
import 'package:pet_lover/fade_animation.dart';
import 'package:pet_lover/model/my_animals_menu_item.dart';
import 'package:pet_lover/model/post.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/commentSection.dart';
import 'package:pet_lover/sub_screens/group_post_add.dart';
import 'package:pet_lover/sub_screens/other_user_profile.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class ShowGroupPost extends StatefulWidget {
  int index;
  Post post;
  ShowGroupPost({required this.index, required this.post});

  @override
  _ShowGroupPostState createState() => _ShowGroupPostState();
}

class _ShowGroupPostState extends State<ShowGroupPost> {
  String _groupName = '';
  String _previousOwnerOfPost = '';
  VideoPlayerController? controller;
  Widget? videoStatusAnimation;
  bool isVisible = true;
  bool _isFollowed = false;
  int _count = 0;
  bool _isSharing = false;

  Future<void> _customInit(String postId, UserProvider userProvider,
      PostProvider postProvider) async {
    setState(() {
      _count++;
    });

    await userProvider.getCurrentUserInfo();

    if (widget.post.groupId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(widget.post.groupId)
          .get()
          .then((snapshot) {
        setState(() {
          _groupName = snapshot['groupName'];
          print('$_groupName');
        });
      });
    }
    if (widget.post.shareId.isNotEmpty) {
      await userProvider.getSpecificUserInfo(widget.post.shareId).then((value) {
        setState(() {
          _previousOwnerOfPost = userProvider.specificUserMap['username'];
        });
      });
    }

    await FirebaseFirestore.instance
        .collection('allPosts')
        .doc(widget.post.postId)
        .collection('followers')
        .doc(userProvider.currentUserMobile)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _isFollowed = true;
        });
      } else {
        setState(() {
          _isFollowed = false;
        });
      }
    });
    print(widget.post.postId);
  }

  Widget buildIndicator() => VideoProgressIndicator(
        controller!,
        allowScrubbing: true,
      );

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.network(widget.post.video)
      ..addListener(() => mounted ? setState(() {}) : true)
      ..setLooping(true)
      ..initialize().then((_) => controller!.play());
  }

  @override
  Widget build(BuildContext context) {
    final AnimalProvider animalProvider = Provider.of<AnimalProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    if (_count == 0)
      _customInit(widget.post.postId, userProvider, postProvider);
    Size size = MediaQuery.of(context).size;
    DateTime miliDate =
        new DateTime.fromMillisecondsSinceEpoch(int.parse(widget.post.date));
    var format = new DateFormat("yMMMd").add_jm();
    String finalDate = format.format(miliDate);

    return Container(
        width: size.width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: size.width * .04,
          ),
          ListTile(
            onTap: () {},
            leading: CircleAvatar(
              backgroundImage: widget.post.postOwnerImage == ''
                  ? AssetImage('assets/profile_image_demo.png')
                  : NetworkImage(widget.post.postOwnerImage) as ImageProvider,
              radius: size.width * .05,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OtherUserProfile(
                                    userId: widget.post.postOwnerId)));
                      },
                      child: Text(
                        widget.post.postOwnerName,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: size.width * .04,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.width * .01),
                Visibility(
                  visible: widget.post.shareId != '' ? true : false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'shared a post of  ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * .04,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OtherUserProfile(
                                      userId: widget.post.shareId)));
                        },
                        child: Container(
                          child: Text(
                            _previousOwnerOfPost,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * .04,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.width * .01),
                Text(
                  finalDate,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * .035,
                  ),
                ),
              ],
            ),
            trailing: Visibility(
              visible: widget.post.postOwnerId == userProvider.currentUserMobile
                  ? true
                  : false,
              child: PopupMenuButton<MyAnimalItemMenu>(
                  onSelected: (item) => onSelectedMenuItem(context, item,
                      animalProvider, postProvider, userProvider),
                  itemBuilder: (context) => [
                        ...CommentEditDelete.commentEditDeleteList
                            .map(buildItem)
                            .toList()
                      ]),
            ),
          ),
          SizedBox(
            height: size.width * .01,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(size.width * .02, size.width * .01,
                size.width * .02, size.width * .01),
            child: Text(
                widget.post.status == '' && widget.post.animalToken != ''
                    ? 'Token: ${widget.post.animalToken}'
                    : widget.post.status,
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: size.width * .038)),
          ),
          SizedBox(
            height: size.width * .02,
          ),
          Visibility(
            visible: widget.post.photo == '' && widget.post.video == ''
                ? false
                : true,
            child: Container(
                width: size.width,
                child: widget.post.photo == '' && widget.post.video == ''
                    ? Container()
                    : widget.post.photo != ''
                        ? Center(
                            child: Image.network(
                            widget.post.photo,
                            fit: BoxFit.fill,
                          ))
                        : Container(
                            width: size.width,
                            height: size.width,
                            child: Center(
                              child: controller!.value.isInitialized
                                  ? Stack(
                                      children: [
                                        AspectRatio(
                                          aspectRatio:
                                              controller!.value.aspectRatio,
                                          child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isVisible = !isVisible;
                                                });

                                                if (!controller!
                                                    .value.isInitialized) {
                                                  return;
                                                }
                                                if (controller!
                                                    .value.isPlaying) {
                                                  videoStatusAnimation =
                                                      FadeAnimation(
                                                          child: const Icon(
                                                              Icons.pause,
                                                              size: 100.0));
                                                  controller!.pause();
                                                } else {
                                                  videoStatusAnimation =
                                                      FadeAnimation(
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
                            ),
                          )),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: size.width * .02),
                child: Text(
                  postProvider.allGroupPost[widget.index].totalFollowers,
                  style: TextStyle(
                      color: Colors.black, fontSize: size.width * .038),
                ),
              ),
              InkWell(
                onTap: () async {
                  setState(() {
                    _isFollowed = !_isFollowed;
                  });
                  if (_isFollowed) {
                    postProvider.addFollowers(
                        widget.post.postId,
                        userProvider.currentUserMap['mobileNo'],
                        null,
                        widget.index,
                        null,
                        null,
                        null);
                    postProvider.setFollowingAndFollower(
                      userProvider.currentUserMap['mobileNo'],
                      postProvider.allPosts[widget.index].postOwnerId,
                      postProvider.allPosts[widget.index].postOwnerName,
                      userProvider.currentUserMap['username'],
                      postProvider.allPosts[widget.index].postOwnerImage,
                      userProvider.currentUserMap['profileImageLink'],
                      userProvider,
                    );
                  }
                  if (_isFollowed == false) {
                    postProvider.removeFollower(
                        widget.post.postId,
                        userProvider.currentUserMobile,
                        null,
                        widget.index,
                        null);
                  }
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
                  postProvider.allGroupPost[widget.index].totalComments,
                  style: TextStyle(
                      color: Colors.black, fontSize: size.width * .038),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommetPage(
                                id: widget.post.postId,
                                animalOwnerMobileNo: widget.post.postOwnerId,
                                allPostIndex: null,
                                groupPostIndex: widget.index,
                                favouriteIndex: null,
                                myPostIndex: null,
                                otherUserPostIndex: null,
                              )));
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(size.width * .02,
                      size.width * .02, size.width * .02, size.width * .02),
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
                  postProvider.allGroupPost[widget.index].totalShares,
                  style: TextStyle(
                      color: Colors.black, fontSize: size.width * .038),
                ),
              ),
              InkWell(
                onTap: () {
                  showAlertDialog(context, widget.post.animalToken,
                      animalProvider, userProvider, postProvider);
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(size.width * .02,
                      size.width * .02, size.width * .02, size.width * .02),
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
                  visible: widget.post.animalName == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Animal name: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalName,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: size.width * .038)),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.post.animalColor == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Color: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalColor,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: size.width * .038)),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.post.animalGenus == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Genus: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalGenus,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: size.width * .038)),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.post.animalGender == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Gender: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalGender,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: size.width * .038)),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.post.animalAge == '' ? false : true,
                  child: Row(
                    children: [
                      Text('Age: ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * .038)),
                      Text(widget.post.animalAge,
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
              backgroundImage:
                  userProvider.currentUserMap['profileImageLink'] == ''
                      ? AssetImage('assets/profile_image_demo.png')
                      : NetworkImage(
                              userProvider.currentUserMap['profileImageLink'])
                          as ImageProvider,
              radius: size.width * .04,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CommetPage(
                            id: widget.post.postId,
                            animalOwnerMobileNo: widget.post.postOwnerId,
                            allPostIndex: null,
                            groupPostIndex: widget.index,
                            favouriteIndex: null,
                            myPostIndex: null,
                            otherUserPostIndex: null,
                          )));
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
        ]));
  }

  showAlertDialog(
      BuildContext context,
      String petId,
      AnimalProvider animalProvider,
      UserProvider userProvider,
      PostProvider postProvider) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = _isSharing == false
        ? TextButton(
            child: Text("Share"),
            onPressed: () {
              setState(() {
                _isSharing = true;
              });
              _sharePost(userProvider, postProvider);
            },
          )
        : CircularProgressIndicator();

    AlertDialog alert = AlertDialog(
      title: Text("Share animal"),
      content: Text("Do you want to share ${widget.post.animalName}?"),
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

  _sharePost(UserProvider userProvider, PostProvider postProvider) async {
    String date = DateTime.now().millisecondsSinceEpoch.toString();
    String postId = Uuid().v4();
    Map<String, String> postMap = {
      'postId': postId,
      'postOwnerId': userProvider.currentUserMap['mobileNo'],
      'postOwnerMobileNo': userProvider.currentUserMap['mobileNo'],
      'postOwnerName': userProvider.currentUserMap['username'],
      'postOwnerImage': userProvider.currentUserMap['profileImageLink'],
      'date': date,
      'status': widget.post.status,
      'photo': widget.post.photo,
      'video': widget.post.video,
      'animalToken': widget.post.animalToken,
      'animalName': widget.post.animalName,
      'animalColor': widget.post.animalColor,
      'animalAge': widget.post.animalAge,
      'animalGender': widget.post.animalGender,
      'animalGenus': widget.post.animalGenus,
      'totalFollowers': '0',
      'totalComments': '0',
      'totalShares': '0',
      'groupId': widget.post.groupId,
      'shareId': widget.post.postOwnerId
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userProvider.currentUserMap['mobileNo'])
        .collection('mySharedPosts')
        .doc(postId)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        Toast().showToast(context, 'Already shared!');
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userProvider.currentUserMap['mobileNo'])
            .collection('myPosts')
            .doc(postId)
            .set({
          'postId': postId,
          'date': date,
        });

        await FirebaseFirestore.instance
            .collection('allPosts')
            .doc(postId)
            .set(postMap);
        int totalShares = 0;
        await FirebaseFirestore.instance
            .collection('allPosts')
            .doc(widget.post.postId)
            .collection('SharingPersons')
            .doc(userProvider.currentUserMap['mobileNo'])
            .set({
          'id': userProvider.currentUserMap['mobileNo'],
        }).then((snapshot) async {
          await FirebaseFirestore.instance
              .collection('allPosts')
              .doc(widget.post.postId)
              .collection('SharingPersons')
              .get()
              .then((snapshot2) async {
            if (snapshot2.docs.length != 0) {
              totalShares = snapshot2.docs.length;
              await FirebaseFirestore.instance
                  .collection('allPosts')
                  .doc(widget.post.postId)
                  .update({'totalShares': totalShares.toString()}).then(
                      (value) {
                postProvider.setTotalShares(widget.post.postId, null,
                    widget.index, null, null, null, userProvider);
                Navigator.pop(context);
                Toast().showToast(context, 'Post shared successfully!');
                setState(() {
                  _isSharing = false;
                });
              });
            }
          });
        });
      }
    });
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

  onSelectedMenuItem(
      BuildContext context,
      MyAnimalItemMenu item,
      AnimalProvider animalProvider,
      PostProvider postProvider,
      UserProvider userProvider) {
    switch (item) {
      case CommentEditDelete.editComment:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GroupPostAdd(
                    groupId: widget.post.groupId, postId: widget.post.postId)));
        break;
      case CommentEditDelete.deleteComment:
        showDeleteAlertDialog(context, postProvider, userProvider);
        break;
    }
  }

  showDeleteAlertDialog(BuildContext context, PostProvider postProvider,
      UserProvider userProvider) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget deleteButton = TextButton(
      child: Text("Delete"),
      onPressed: () {
        postProvider
            .deleteGroupPost(widget.post.photo, widget.post.postId,
                widget.post.groupId, widget.index)
            .then((value) {
          Navigator.pop(context);
          Toast().showToast(context, 'Deleted successfully.');
          postProvider.userPosts.removeAt(widget.index);
        });
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Delete animal"),
      content: Text("Do you want to delete ${widget.post.animalName}?"),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
