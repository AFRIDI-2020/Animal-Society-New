import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/fade_animation.dart';
import 'package:pet_lover/model/post.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class TokenSearch extends StatefulWidget {
  const TokenSearch({Key? key}) : super(key: key);

  @override
  _TokenSearchState createState() => _TokenSearchState();
}

class _TokenSearchState extends State<TokenSearch> {
  TextEditingController _searchController = TextEditingController();
  bool? _loading;
  VideoPlayerController? controller;
  bool isVisible = true;
  Widget? videoStatusAnimation;
  bool _tokenExists = false;

  Widget buildIndicator() => VideoProgressIndicator(
        controller!,
        allowScrubbing: true,
      );

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final PostProvider postProvider = Provider.of<PostProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0.0,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Search Token",
              style: TextStyle(
                color: Colors.black,
                fontSize: size.width * .05,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
            width: size.width,
            child: Column(
              children: [
                SizedBox(height: size.width * .04),
                searchBar(context, postProvider, userProvider),
                SizedBox(height: size.width * .04),
                Expanded(
                  child: Container(
                      width: size.width,
                      child: _loading == true
                          ? Center(child: CircularProgressIndicator())
                          : _tokenExists == false
                              ? Center(child: Text('No such token.'))
                              : ListView.builder(
                                  physics: ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount:
                                      postProvider.searchedTokenList.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: size.width,
                                      child: Column(
                                        children: [
                                          Container(
                                              width: size.width,
                                              child: postProvider
                                                          .searchedTokenList[
                                                              index]
                                                          .photo !=
                                                      ''
                                                  ? Center(
                                                      child: Image.network(
                                                      postProvider
                                                          .searchedTokenList[
                                                              index]
                                                          .photo,
                                                      fit: BoxFit.fill,
                                                    ))
                                                  : Center(
                                                      child: controller!.value
                                                              .isInitialized
                                                          ? Stack(
                                                              children: [
                                                                AspectRatio(
                                                                  aspectRatio:
                                                                      controller!
                                                                          .value
                                                                          .aspectRatio,
                                                                  child:
                                                                      GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              isVisible = !isVisible;
                                                                            });

                                                                            if (!controller!.value.isInitialized) {
                                                                              return;
                                                                            }
                                                                            if (controller!.value.isPlaying) {
                                                                              videoStatusAnimation = FadeAnimation(child: const Icon(Icons.pause, size: 100.0));
                                                                              controller!.pause();
                                                                            } else {
                                                                              videoStatusAnimation = FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
                                                                              controller!.play();
                                                                            }
                                                                          },
                                                                          child:
                                                                              VideoPlayer(controller!)),
                                                                ),
                                                                Positioned.fill(
                                                                    child:
                                                                        Stack(
                                                                  children: <
                                                                      Widget>[
                                                                    Center(
                                                                        child:
                                                                            videoStatusAnimation),
                                                                    Positioned(
                                                                      bottom: 0,
                                                                      left: 0,
                                                                      right: 0,
                                                                      child:
                                                                          buildIndicator(),
                                                                    ),
                                                                  ],
                                                                ))
                                                              ],
                                                            )
                                                          : CircularProgressIndicator(),
                                                    )),
                                          Container(
                                            width: size.width,
                                            padding: EdgeInsets.all(
                                                size.width * .04),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Visibility(
                                                  visible: postProvider
                                                              .searchedTokenList[
                                                                  index]
                                                              .animalName ==
                                                          ''
                                                      ? false
                                                      : true,
                                                  child: Row(
                                                    children: [
                                                      Text('Animal name: ',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize:
                                                                  size.width *
                                                                      .038)),
                                                      Text(
                                                          postProvider
                                                              .searchedTokenList[
                                                                  index]
                                                              .animalName,
                                                          style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade700,
                                                              fontSize:
                                                                  size.width *
                                                                      .038)),
                                                    ],
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: postProvider
                                                              .searchedTokenList[
                                                                  index]
                                                              .animalColor ==
                                                          ''
                                                      ? false
                                                      : true,
                                                  child: Row(
                                                    children: [
                                                      Text('Color: ',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize:
                                                                  size.width *
                                                                      .038)),
                                                      Text(
                                                          postProvider
                                                              .searchedTokenList[
                                                                  index]
                                                              .animalColor,
                                                          style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade700,
                                                              fontSize:
                                                                  size.width *
                                                                      .038)),
                                                    ],
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: postProvider
                                                              .searchedTokenList[
                                                                  index]
                                                              .animalGenus ==
                                                          ''
                                                      ? false
                                                      : true,
                                                  child: Row(
                                                    children: [
                                                      Text('Genus: ',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize:
                                                                  size.width *
                                                                      .038)),
                                                      Text(
                                                          postProvider
                                                              .searchedTokenList[
                                                                  index]
                                                              .animalGenus,
                                                          style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade700,
                                                              fontSize:
                                                                  size.width *
                                                                      .038)),
                                                    ],
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: postProvider
                                                              .searchedTokenList[
                                                                  index]
                                                              .animalGender ==
                                                          ''
                                                      ? false
                                                      : true,
                                                  child: Row(
                                                    children: [
                                                      Text('Gender: ',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize:
                                                                  size.width *
                                                                      .038)),
                                                      Text(
                                                          postProvider
                                                              .searchedTokenList[
                                                                  index]
                                                              .animalGender,
                                                          style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade700,
                                                              fontSize:
                                                                  size.width *
                                                                      .038)),
                                                    ],
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: postProvider
                                                              .searchedTokenList[
                                                                  index]
                                                              .animalAge ==
                                                          ''
                                                      ? false
                                                      : true,
                                                  child: Row(
                                                    children: [
                                                      Text('Age: ',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize:
                                                                  size.width *
                                                                      .038)),
                                                      Text(
                                                          postProvider
                                                              .searchedTokenList[
                                                                  index]
                                                              .animalAge,
                                                          style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade700,
                                                              fontSize:
                                                                  size.width *
                                                                      .038)),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: size.width * .04,
                                                ),
                                                Text('Owner information',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey.shade700,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            size.width * .05)),
                                                SizedBox(
                                                  height: size.width * .02,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text('Name: ',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        fontSize:
                                                                            size.width *
                                                                                .038)),
                                                                Text(
                                                                    userProvider
                                                                            .specificUserMap[
                                                                        'username'],
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade700,
                                                                        fontSize:
                                                                            size.width *
                                                                                .038)),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                    'Address: ',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        fontSize:
                                                                            size.width *
                                                                                .038)),
                                                                Text(
                                                                    userProvider
                                                                            .specificUserMap[
                                                                        'address'],
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade700,
                                                                        fontSize:
                                                                            size.width *
                                                                                .038)),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text('Mobile: ',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        fontSize:
                                                                            size.width *
                                                                                .04)),
                                                                Text(
                                                                    userProvider
                                                                            .specificUserMap[
                                                                        'mobileNo'],
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade700,
                                                                        fontSize:
                                                                            size.width *
                                                                                .04)),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    CircleAvatar(
                                                      radius: size.width * .08,
                                                      backgroundImage: userProvider
                                                                      .specificUserMap[
                                                                  'profileImageLink'] ==
                                                              ''
                                                          ? AssetImage(
                                                              'assets/profile_image_demo.png')
                                                          : NetworkImage(userProvider
                                                                      .specificUserMap[
                                                                  'profileImageLink'])
                                                              as ImageProvider,
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  })),
                )
              ],
            )));
  }

  Widget searchBar(BuildContext context, PostProvider postProvider,
      UserProvider userProvider) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: EdgeInsets.only(left: size.width * .04, right: size.width * .04),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.width * .25),
                color: Colors.grey[300],
              ),
              padding: EdgeInsets.fromLTRB(
                  0, size.width * .02, size.width * .02, size.width * .02),
              child: TextFormField(
                cursorColor: Colors.black,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Token',
                  hintStyle: TextStyle(color: Colors.black),
                  isDense: true,
                  contentPadding: EdgeInsets.only(left: size.width * .04),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(
            width: size.width * .02,
          ),
          InkWell(
            onTap: () async {
              setState(() {
                _loading = true;
              });
              _tokenExists = await postProvider.searchToken(
                  _searchController.text, userProvider);
              setState(() {
                _loading = false;
              });
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(
                size.width * .04,
                size.width * .02,
                size.width * .04,
                size.width * .02,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size.width * .25),
                  color: Colors.grey[300]),
              child: Text(
                'Search',
                style: TextStyle(color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }
}
