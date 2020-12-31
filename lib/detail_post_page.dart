import 'package:chapter10/tab_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPostPage extends StatelessWidget {
  final DocumentSnapshot document;
  final FirebaseUser user;

  DetailPostPage(this.document, this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('상세 포스트'),
            IconButton(
              icon: Icon(
                Icons.delete,
              ),
              alignment: Alignment.centerRight,
              onPressed: () {
                Firestore.instance
                    .collection('post')
                    .document(document.documentID)
                    .delete();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TabPage(user),
                    ));
              },
            ),
          ],
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage(document['userPhotoUrl']),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            document['displayName'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          // Spacer(),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Hero(
            tag: document.documentID,
            child: Image.network(
              document['photoUrl'],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(document['contents']),
          ),
        ],
      ),
    );
  }

  // 팔로우
  void _follow() {
    Firestore.instance
        .collection('following')
        .document(user.email)
        .setData({document['email']: true});
    Firestore.instance
        .collection('follower')
        .document(document['email'])
        .setData({user.email: true});
  }

  // 언팔로우
  void _unfollow() {
    Firestore.instance
        .collection('following')
        .document(user.email)
        .setData({document['email']: false});
    Firestore.instance
        .collection('follower')
        .document(document['email'])
        .setData({user.email: false});
  }

  // 팔로잉 상태를 얻는 스트림
  Stream<DocumentSnapshot> _followingStream() {
    return Firestore.instance
        .collection('following')
        .document(user.email)
        .snapshots();
  }
}
