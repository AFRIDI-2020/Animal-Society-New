import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_lover/demo_designs/showPost.dart';
import 'package:pet_lover/model/post.dart';
import 'package:pet_lover/provider/postProvider.dart';
import 'package:pet_lover/sub_screens/animalNameSearchShow.dart';
import 'package:provider/provider.dart';

class AnimalNameSearch extends StatefulWidget {
  const AnimalNameSearch({Key? key}) : super(key: key);

  @override
  _AnimalNameSearchState createState() => _AnimalNameSearchState();
}

class _AnimalNameSearchState extends State<AnimalNameSearch> {
  TextEditingController _searchController = TextEditingController();
  bool _loading = false;
  int _count = 0;
  List<Post> _animalList = [];

  List<Post> _searchList = [];

  Future<void> _customInit(PostProvider postProvider) async {
    setState(() {
      _count++;
      _loading = true;
    });

    await postProvider.getAllAnimals().then((value) {
      _animalList = postProvider.animalList;
    });

    setState(() {
      _loading = false;
    });
  }

  _searchAnimal(String searchItem) {
    setState(() {
      if (searchItem == '') {
        searchItem = 'sdfsfafvsdvfsfsdf';
      }
      _searchList = _animalList
          .where((element) => (element.animalName
              .toLowerCase()
              .contains(searchItem.toLowerCase())))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final PostProvider postProvider = Provider.of<PostProvider>(context);
    if (_count == 0) _customInit(postProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Search",
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
      body: Column(
        children: [
          searchBar(context, postProvider),
          Expanded(
            child: Container(
                width: size.width,
                child: _loading
                    ? Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: size.width * .08),
                          Text(
                            'Loading animals. Please wait...',
                            style: TextStyle(
                              fontSize: size.width * .04,
                            ),
                          ),
                        ],
                      ))
                    : ListView.builder(
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _searchList.length,
                        itemBuilder: (context, index) {
                          return AnimalNameSearchPostShow(
                              index: index, post: _searchList[index]);
                        })),
          )
        ],
      ),
    );
  }

  Widget searchBar(BuildContext context, PostProvider postProvider) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: EdgeInsets.only(left: size.width * .04, right: size.width * .04),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.width * .25),
          color: Colors.grey[300],
        ),
        padding: EdgeInsets.fromLTRB(
            0, size.width * .02, size.width * .02, size.width * .02),
        child: TextFormField(
          onChanged: _searchAnimal,
          cursorColor: Colors.black,
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Animal name',
            hintStyle: TextStyle(color: Colors.black),
            isDense: true,
            contentPadding: EdgeInsets.only(left: size.width * .04),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
