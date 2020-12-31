import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'create_page.dart';
import 'create_relay_page.dart';
import 'detail_post_page.dart';

class RelayPage extends StatelessWidget {
  final FirebaseUser user;
  final DocumentSnapshot document;

  RelayPage(this.document, this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'For Your Long Run',
        style: GoogleFonts.pacifico(),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.send),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    CreateRelayPage(document, user)));
          },
        )
      ],
    );
  }

  Widget _buildBody(context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Text(
                '   스타트 포스트 ',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                textAlign: TextAlign.left,
              ),
              Icon(
                Icons.emoji_people,
                // color: Colors.red,
              ),
            ],
          ),
          Divider(color: Colors.black),
          StreamBuilder<DocumentSnapshot>(
              stream: _startPostStream(),
              builder: (context, snapshot) {
                return GridView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0),
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildListItem(context, snapshot.data);
                  },
                );
              }),
          SizedBox(
            height: 19,
          ),
          Row(
            children: [
              Text(
                '   릴레이 포스트  ',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                textAlign: TextAlign.left,
              ),
              Icon(
                Icons.directions_run,
                // color: Colors.red,
              ),
            ],
          ),
          Divider(color: Colors.black,),
          StreamBuilder<QuerySnapshot>(
              stream: _relayPostStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return GridView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 1.0,
                      crossAxisSpacing: 1.0),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildListItem(
                        context, snapshot.data.documents[index]);
                  },
                );
              }),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Hero(
      tag: document.toString(),
      child: Material(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailPostPage(document, user)),
            );
          },
          child: Image.network(
            document['photoUrl'],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Stream<DocumentSnapshot> _startPostStream() {
    return Firestore.instance
        .collection('post')
        .document(document.documentID)
        .snapshots();
  }

  Stream<QuerySnapshot> _relayPostStream() {
    return Firestore.instance
        .collection('post')
        .document(document.documentID)
        .collection('relay')
        .snapshots();
  }
}
