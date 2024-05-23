import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';

class ShowResultsScreen extends StatelessWidget {
  static const String routeName = '/show_results';
  final  resultsDisplayed;

  const ShowResultsScreen({Key? key, required this.resultsDisplayed, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Voting Results'),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple, Colors.deepPurple],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: resultsDisplayed ? const BuildResults() : const BuildPendingScreen(),
      ),
    );
  }
}

class BuildResults extends StatelessWidget {
  const BuildResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('competitors').snapshots(),
      builder: (context, competitorsSnapshot) {
        if (competitorsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (competitorsSnapshot.hasError) {
          return Center(
            child: Text('Error: ${competitorsSnapshot.error}'),
          );
        }
        if (!competitorsSnapshot.hasData || competitorsSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No data available.'),
          );
        }

        List<DocumentSnapshot> competitors = competitorsSnapshot.data!.docs;
        int maxVotes = 0;

        // Find the competitor with the highest votes
        for (var competitor in competitors) {
          int votes = competitor['votes'] ?? 0;
          maxVotes = maxVotes < votes ? votes : maxVotes;
        }

        return ListView.builder(
          itemCount: competitors.length,
          itemBuilder: (context, index) {
            var competitor = competitors[index];
            bool isWinner = competitor['votes'] == maxVotes;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(competitor['imageUrl']),
                ),
                title: Text(competitor['name']),
                subtitle: isWinner ? Text('Winner', style: TextStyle(color: Colors.green)) : null,
                trailing: Text('Votes: ${competitor['votes']}'),
              ),
            );
          },
        );
      },
    );

  }
}

class BuildPendingScreen extends StatelessWidget {
  const BuildPendingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Results are not yet displayed',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
