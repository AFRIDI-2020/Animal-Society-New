import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/provider/animalProvider.dart';
import 'package:pet_lover/provider/userProvider.dart';
import 'package:pet_lover/utils/message_stream.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  String? followingName,
      followingNumber,
      followerName,
      followerNumber,
      followingImage,
      followerImage;

  ChatPage(
      {this.followingName,
      this.followingNumber,
      this.followerName,
      this.followerNumber,
      this.followingImage,
      this.followerImage});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final messageTextController = TextEditingController();
  String? messageText;
  bool _isLoading = false;
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   messageTextController.text = '';
  //   messageText = messageTextController.text;
  // }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () => _onBackPressed(userProvider),
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () async {
                  AnimalProvider animalProvider =
                      Provider.of<AnimalProvider>(context, listen: false);
                  await animalProvider
                      .updateSeen(
                          widget.followerNumber!, widget.followingNumber!)
                      .then((value) {
                    animalProvider.getAllChatUser(userProvider).then((value) {
                      Navigator.pop(context);
                    });
                  });
                }),
            toolbarHeight: size.height * .08,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                widget.followingNumber ==
                        userProvider.currentUserMap['mobileNo']
                    ? CircleAvatar(
                        backgroundImage: widget.followerImage == ''
                            ? AssetImage('assets/profile_image_demo.png')
                            : NetworkImage(widget.followerImage!)
                                as ImageProvider,
                        radius: size.width * .05,
                      )
                    : CircleAvatar(
                        backgroundImage: widget.followingImage == ''
                            ? AssetImage('assets/profile_image_demo.png')
                            : NetworkImage(widget.followingImage!)
                                as ImageProvider,
                        radius: size.width * .05,
                      ),
                SizedBox(width: 15),
                widget.followingNumber ==
                        userProvider.currentUserMap['mobileNo']
                    ? Text(widget.followerName!,
                        style: TextStyle(color: Colors.black))
                    : Text(widget.followingName!,
                        style: TextStyle(color: Colors.black)),
              ],
            )),
        body: Stack(
          children: [
            _bodyUi(),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Container()
          ],
        ),
      ),
    );
  }

  Widget _bodyUi() {
    final size = MediaQuery.of(context).size;
    AnimalProvider animalProvider =
        Provider.of<AnimalProvider>(context, listen: false);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    return Container(
      child: Stack(
        children: [
          RechargeMessageStream(
              followingName: widget.followingName,
              followingNumber: widget.followingNumber,
              followerName: widget.followerName,
              followerNumber: widget.followerNumber,
              sender: userProvider.currentUserMap['mobileNo']),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: size.width * .20,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: size.width * .04,
                  ),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      expands: true,
                      controller: messageTextController,
                      style: TextStyle(color: Colors.black),
                      //textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      enableSuggestions: true,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(5),
                        hintStyle: TextStyle(color: Colors.blueGrey),
                        hintText: 'Write your message..',
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: const BorderSide(
                            color: Color(0xFF4A8789),
                            width: 0.5,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        messageText = value;
                      },
                    ),
                  ),
                  SizedBox(
                    width: size.width * .04,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: size.width * .04),
                    child: FloatingActionButton(
                      onPressed: () {
                        if (messageTextController.text != '') {
                          animalProvider.uploadMessage(
                              messageText!,
                              userProvider.currentUserMap['username'],
                              userProvider.currentUserMap['mobileNo'],
                              widget.followerNumber!,
                              widget.followingNumber!,
                              widget.followingName!,
                              widget.followerName!);
                        }
                        messageTextController.clear();
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: size.width * .06,
                      ),
                      backgroundColor: Colors.deepOrange,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onBackPressed(UserProvider userProvider) async {
    AnimalProvider animalProvider =
        Provider.of<AnimalProvider>(context, listen: false);
    await animalProvider
        .updateSeen(widget.followerNumber!, widget.followingNumber!)
        .then((value) {
      animalProvider.getAllChatUser(userProvider).then((value) {
        Navigator.pop(context);
      });
    });
    return false;
  }
}
