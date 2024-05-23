// umehani.bscssef20@iba-suk.edu.pk

import 'package:flutter/material.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'addcompititor.dart';
import 'reults.dart';
import 'candidate_detail.dart'; // Import the new detail page

class VotingPage extends StatefulWidget {
  static const String routeName = '/voting';

  const VotingPage({Key? key}) : super(key: key);

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool resultsDisplayed = false;

  final email = FirebaseAuth.instance.currentUser!.email;
  bool admin = false;

  Future<void> _voteForCompetitor(String docId) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userVoteDoc =
            await _firestore.collection('votes').doc(user.email).get();

        if (userVoteDoc.exists) {

          // code to update vote
          // await _firestore.collection('votes').doc(user.email).update({
          //   'competitorId': docId,
          //   'userId': user.email,
          // });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have already cast your vote!'),
            ),
          );
        } else {
          await _firestore.collection('votes').doc(user.email).set({
            'competitorId': docId,
            'userId': user.email,
          });

          DocumentReference competitorRef =
          _firestore.collection('competitors').doc(docId);
          await _firestore.runTransaction((transaction) async {
            DocumentSnapshot snapshot = await transaction.get(competitorRef);
            if (!snapshot.exists) {
              throw Exception("Competitor does not exist!");
            }
            int newVotes = (snapshot['votes'] as int) + 1;
            transaction.update(competitorRef, {'votes': newVotes});
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vote cast successfully!'),
            ),
          );
        }


      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cast vote. Please try again.'),
        ),
      );
    }
  }

  Future<void> _fetchResults() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('display_result').get();
      if (querySnapshot.docs.isNotEmpty) {
        for (var element in querySnapshot.docs) {
          if (element['showResults'] == true) {
            print(element['showResults']);
            resultsDisplayed = true;
            break;
          }
        }
      }
    } catch (error) {
      print("Error fetching results: $error");
    }
  }
  @override
  Widget build(BuildContext context) {

    if (email == 'umehani.bscssef20@iba-suk.edu.pk') {
      admin = true;
    }
    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Cast Vote'),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple, Colors.deepPurple],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () async {
              await _fetchResults();
              Navigator.pushNamed(context, ShowResultsScreen.routeName, arguments: resultsDisplayed);
            },
          ),
          Visibility(
            visible: admin,
              child: IconButton(
            icon: const Icon(Icons.access_alarm),
            onPressed: () {
              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  title: const Text('Show Results'),
                  content: const Text('Do you want to show results?'),
                  actions: <Widget>[

                    TextButton(
                      child: const Text('Hide'),
                      onPressed: () {
                        FirebaseFirestore.instance.collection('display_result').get().then((snapshot) {
                          for (DocumentSnapshot doc in snapshot.docs) {
                            doc.reference.update({'showResults': false});
                          }
                        });
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Results are hidden!'),
                          ),
                        );

                      //   show
                      },
                    ),

                    TextButton(
                      child: const Text('Show'),
                      onPressed: () {
                        FirebaseFirestore.instance.collection('display_result').get().then((snapshot) {
                          for (DocumentSnapshot doc in snapshot.docs) {
                            doc.reference.update({'showResults': true});
                          }
                        });
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Results are shown!'),
                          ),
                        );
                      },
                    ),
                  ],
                );
              });


            },
          ))
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('competitors').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            var competitors = snapshot.data!.docs;

            return ListView.builder(
              itemCount: competitors.length,
              itemBuilder: (context, index) {
                var competitor = competitors[index];
                return Card(
                  color: Colors.white.withOpacity(0.8),
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: ListTile(
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipPath(
                          clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Image.network(
                            competitor['imageUrl'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          competitor['name'],
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Vote'),
                              content: const Text(
                                  'Are you sure you want to cast your vote?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Yes'),
                                  onPressed: () {
                                    _voteForCompetitor(competitor.id);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Vote'),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CandidateDetailPage(
                            candidate: competitor,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Visibility(
        visible: admin,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, AddCompetitorPage.routeName);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
