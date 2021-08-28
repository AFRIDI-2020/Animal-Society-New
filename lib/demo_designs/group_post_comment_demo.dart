import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/demo_designs/comment_edit_delete.dart';
import 'package:pet_lover/model/Comment.dart';
import 'package:pet_lover/model/my_animals_menu_item.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/groupProvider.dart';
import 'package:provider/provider.dart';

class GroupPostCommentDemo extends StatefulWidget {
  int? index;
  Comment? comment;
  GroupPostCommentDemo({this.index, this.comment});

  @override
  _GroupPostCommentDemoState createState() => _GroupPostCommentDemoState();
}

class _GroupPostCommentDemoState extends State<GroupPostCommentDemo> {
  String? date;
  TextEditingController _editCommentController = TextEditingController();
  bool _editVisibility = false;
  bool _commentVisibility = true;
  String? _commenterImage;
  String? _commenterName;

  Future _getCommenter(String commenter) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(commenter)
        .get()
        .then((snapshot) {
      setState(() {
        _commenterImage = snapshot['profileImageLink'];
        _commenterName = snapshot['username'];
      });
    });
  }

  _getCommentsTime() {
    DateTime now = DateTime.now();
    int commentDurationInSec = now
        .difference(DateTime.fromMillisecondsSinceEpoch(
            int.parse(widget.comment!.date!)))
        .inSeconds;
    int day = commentDurationInSec ~/ (24 * 3600);
    commentDurationInSec = commentDurationInSec % (24 * 3600);
    int hour = commentDurationInSec ~/ 3600;
    commentDurationInSec %= 3600;
    int min = commentDurationInSec ~/ 60;
    commentDurationInSec %= 60;
    int sec = commentDurationInSec;

    if (day == 0 && hour == 0 && min == 0 && sec < 60) {
      date = 'just now';
    } else if (day == 0 && hour == 0 && min != 0 && sec < 60) {
      date = min.toString() + ' min';
    } else if (day == 0 && hour != 0 && min != 0 && sec != 0) {
      date = hour.toString() + ' hour' + ' ' + min.toString() + ' min';
    }
  }

  @override
  Widget build(BuildContext context) {
    final AnimalProvider animalProvider = Provider.of<AnimalProvider>(context);
    final GroupProvider groupProvider = Provider.of<GroupProvider>(context);
    Size size = MediaQuery.of(context).size;
    _getCommenter(widget.comment!.currentUserMobileNo!);
    _getCommentsTime();

    return Container(
      width: size.width,
      padding: EdgeInsets.all(size.width * .03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: _commenterImage == null || _commenterImage == ''
                ? AssetImage('assets/profile_image_demo.png')
                : NetworkImage(_commenterImage!) as ImageProvider,
            radius: size.width * .04,
          ),
          Container(
            width: size.width * .8,
            padding: EdgeInsets.only(left: size.width * .03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: _commentVisibility,
                  child: Container(
                    padding: EdgeInsets.only(
                        left: size.width * .04,
                        top: size.width * .03,
                        bottom: size.width * .03),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(size.width * .02)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: size.width * .6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(
                                  _commenterName == null ? '' : _commenterName!,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: size.width * .04),
                                ),
                              ),
                              Text(
                                widget.comment!.comment!,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * .04),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<MyAnimalItemMenu>(
                            onSelected: (item) => onSelectedMenuItem(
                                context, item, groupProvider),
                            itemBuilder: (context) => [
                                  ...CommentEditDelete.commentEditDeleteList
                                      .map(buildItem)
                                      .toList()
                                ]),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: _editVisibility,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          child: TextFormField(
                            controller: _editCommentController,
                            decoration: InputDecoration(),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            // setState(() {
                            //   groupProvider
                            //       .editComment(
                            //           widget.comment!.animalId!,
                            //           widget.comment!.id!,
                            //           _editCommentController.text)
                            //       .then((value) {
                            //     _editVisibility = false;
                            //     _commentVisibility = true;
                            //   });
                            // });
                          },
                          icon: Icon(Icons.add_circle)),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * .02,
                ),
                Padding(
                  padding: EdgeInsets.only(left: size.width * .04),
                  child: Text(
                    date!,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
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
      GroupProvider groupProvider) {
    switch (item) {
      case CommentEditDelete.editComment:
        setState(() {
          _commentVisibility = false;
          _editVisibility = true;
          _editCommentController.text = widget.comment!.comment!;
        });

        break;
      case CommentEditDelete.deleteComment:
        // groupProvider.deleteComment(
        //     widget.comment!.animalId!, widget.comment!.id!);
        break;
    }
  }
}
