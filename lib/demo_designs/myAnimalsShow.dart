import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_lover/custom_classes/toast.dart';
import 'package:pet_lover/fade_animation.dart';
import 'package:pet_lover/model/post.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/sub_screens/commentSection.dart';
import 'package:pet_lover/sub_screens/groupDetail.dart';
import 'package:pet_lover/sub_screens/other_user_profile.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class MyAnimalsShow extends StatefulWidget {
  int index;
  Post post;
  MyAnimalsShow({required this.index, required this.post});

  @override
  _MyAnimalsShowState createState() => _MyAnimalsShowState();
}

class _MyAnimalsShowState extends State<MyAnimalsShow> {
  String _groupName = '';
  String _previousOwnerOfPost = '';
  VideoPlayerController? controller;
  Widget? videoStatusAnimation;
  bool isVisible = true;
  bool _isFollowed = false;
  int _count = 0;
  bool _isSharing = false;

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
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AnimalProvider animalProvider = Provider.of<AnimalProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final PostProvider postProvider = Provider.of<PostProvider>(context);
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
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * .045)),
          ),
          SizedBox(
            height: size.width * .02,
          ),
          Visibility(
            visible: widget.post.photo == '' && widget.post.video == ''
                ? false
                : true,
            child: InkWell(
              onDoubleTap: () {},
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
                                                                Icons
                                                                    .play_arrow,
                                                                size: 100.0));
                                                    controller!.play();
                                                  }
                                                },
                                                child:
                                                    VideoPlayer(controller!)),
                                          ),
                                          Positioned.fill(
                                              child: Stack(
                                            children: <Widget>[
                                              Center(
                                                  child: videoStatusAnimation),
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
}
