import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/demo_designs/comments.dart';
import 'package:pet_lover/demo_designs/group_post_comment_demo.dart';
import 'package:pet_lover/model/Comment.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/groupProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class GroupCommentSection extends StatefulWidget {
  String id;
  String postOwnerMobileNo;
  int index;

  GroupCommentSection(
      {required this.id, required this.postOwnerMobileNo, required this.index});

  @override
  _GroupCommentSectionState createState() =>
      _GroupCommentSectionState(id, postOwnerMobileNo, index);
}

class _GroupCommentSectionState extends State<GroupCommentSection> {
  TextEditingController _commentController = TextEditingController();
  Map<String, String> _currentUserInfoMap = {};

  int _count = 0;
  String id;
  String postOwnerMobileNo;
  int index;

  _GroupCommentSectionState(this.id, this.postOwnerMobileNo, this.index);

  List<Comment> commentList = [];
  bool _loading = false;

  Future<void> _customInit(UserProvider userProvider) async {
    setState(() {
      _count++;
    });
    await userProvider.getCurrentUserInfo().then((value) {
      setState(() {
        _currentUserInfoMap = userProvider.currentUserMap;
        print(
            'The profile image in comment section = ${_currentUserInfoMap['profileImageLink']!}');
      });
    });
  }

  @override
  void initState() {
    print('groupCommentSection');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final AnimalProvider animalProvider = Provider.of<AnimalProvider>(context);
    final GroupProvider groupProvider = Provider.of<GroupProvider>(context);
    if (_count == 0) _customInit(userProvider);
    Size size = MediaQuery.of(context).size;
    AppBar appBar = AppBar();
    double appbar_height = appBar.preferredSize.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        elevation: 0.0,
        title: Text(
          'Comments',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            // StreamBuilder(
            //     stream: FirebaseFirestore.instance
            //         .collection('groupPosts')
            //         .doc(id)
            //         .collection('comments')
            //         .orderBy('date', descending: true)
            //         .snapshots(),
            //     builder: (BuildContext context,
            //         AsyncSnapshot<QuerySnapshot> snapshot) {
            //       return snapshot.data == null
            //           ? Center(child: CircularProgressIndicator())
            //           : ListView.builder(
            //               physics: ClampingScrollPhysics(),
            //               shrinkWrap: true,
            //               itemCount: snapshot.data!.docs.length,
            //               itemBuilder: (context, index) {
            //                 var comments = snapshot.data!.docs;

            //                 Comment comment = Comment(
            //                     id: comments[index]['commentId'],
            //                     comment: comments[index]['comment'],
            //                     animalOwnerMobileNo: comments[index]
            //                         ['animalOwnerMobileNo'],
            //                     currentUserMobileNo: comments[index]
            //                         ['commenter'],
            //                     date: comments[index]['date'],
            //                     totalLikes: comments[index]['totalLikes'],
            //                     animalId: id);

            //                 return GroupPostCommentDemo(
            //                   index: index,
            //                   comment: comment,
            //                 );
            //               });
            //     }),
            Positioned(
              bottom: 0.0,
              child: Container(
                  width: size.width,
                  height: appbar_height,
                  color: Colors.white,
                  child: Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    elevation: size.width * .04,
                    child: Row(
                      children: [
                        Container(
                          width: size.width * .8,
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    size.width * .03, 0.0, 0.0, 0.0),
                                child: CircleAvatar(
                                  backgroundImage: (_currentUserInfoMap[
                                                  'profileImageLink'] ==
                                              null ||
                                          _currentUserInfoMap[
                                                  'profileImageLink'] ==
                                              '')
                                      ? AssetImage(
                                          'assets/profile_image_demo.png')
                                      : NetworkImage(_currentUserInfoMap[
                                              'profileImageLink']!)
                                          as ImageProvider,
                                  radius: size.width * .04,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(size.width * .03,
                                    0.0, size.width * .03, 0.0),
                                width: size.width * .6,
                                child: _commentField(context),
                              ),
                            ],
                          ),
                        ),
                        _loading
                            ? CircularProgressIndicator()
                            : TextButton(
                                onPressed: () {
                                  if (_commentController.text.isEmpty) {
                                    return;
                                  }

                                  final _commentId = Uuid().v4();
                                  String date = DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString();
                                  _postComment(
                                      groupProvider,
                                      id,
                                      _commentId,
                                      _commentController.text,
                                      postOwnerMobileNo,
                                      _currentUserInfoMap['mobileNo']!,
                                      date);
                                },
                                child: Text(
                                  'Post',
                                  style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: size.width * .038),
                                ),
                              )
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  _postComment(
      GroupProvider groupProvider,
      String postId,
      String commentId,
      String comment,
      String postOwnerMobileNo,
      String currentUserMobileNo,
      String date) async {
    setState(() {
      _loading = true;
    });
    await groupProvider
        .addGroupPostComment(postId, commentId, comment, postOwnerMobileNo,
            currentUserMobileNo, date, '')
        .then((value) {
      setState(() {
        _commentController.clear();
        _loading = false;
      });
    });
  }

  Widget _commentField(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return TextFormField(
      controller: _commentController,
      decoration: InputDecoration(
        hintText: 'Add a comment',
        hintStyle: TextStyle(
          fontSize: size.width * .04,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      cursorColor: Colors.black,
    );
  }
}
