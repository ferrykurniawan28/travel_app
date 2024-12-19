import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/auth/signin.dart';
import 'package:travel_app/create.dart';
import 'package:travel_app/models/places.dart';
import 'package:travel_app/view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final db = FirebaseFirestore.instance;
  List<Places> places = [];

  Future<void> getUserPlaces() async {
    db
        .collection('places')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      final List<Places> loadedPlaces = [];
      for (var element in value.docs) {
        loadedPlaces.add(Places(
          title: element['title'],
          description: element['description'],
          imageUrl: element['imageUrl'],
        ));
      }
      setState(() {
        places = loadedPlaces;
      });
    });
  }

  @override
  void initState() {
    getUserPlaces();
    super.initState();
  }

  Future<void> refresh() async {
    await getUserPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const CreatePlaceScreen();
              }));
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // sign out
              final FirebaseAuth _auth = FirebaseAuth.instance;
              await _auth.signOut();

              // navigate to sign in screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SignInScreen()));
            },
          ),
        ],
      ),
      body: places.isEmpty
          ? RefreshIndicator(
              onRefresh: refresh,
              child: SingleChildScrollView(
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('No places added yet'),
                    ],
                  ),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                itemCount: places.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ViewPlace(
                          placeName: places[index].title,
                          description: places[index].description,
                          imageUrl: places[index].imageUrl,
                        );
                      }));
                    },
                    title: Text(places[index].title),
                    subtitle: Text(places[index].description,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    leading: Image.network(places[index].imageUrl),
                  );
                },
              ),
            ),
    );
  }
}
