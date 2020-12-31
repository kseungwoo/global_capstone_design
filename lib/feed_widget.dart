import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'comment_page.dart';
import 'create_page.dart';
import 'relay_page.dart';

class FeedWidget extends StatefulWidget {
  final DocumentSnapshot document;

  final FirebaseUser user;

  FeedWidget(this.document, this.user);

  @override
  _FeedWidgetState createState() => _FeedWidgetState();
}

class _FeedWidgetState extends State<FeedWidget> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var commentCount = widget.document['commentCount'] ?? 0;
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.document['userPhotoUrl']),
          ),
          title: Text(
            widget.document['displayName'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // trailing: Icon(Icons.more_vert),
          // trailing: Icon(Icons.send),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 6.0,
              ),
              StreamBuilder<DocumentSnapshot>(
                  stream: _followingStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text('로딩중');
                    }

                    var data = snapshot.data.data;

                    if ((data == null ||
                            data[widget.document['email']] == null ||
                            data[widget.document['email']] == false) &&
                        widget.document['email'] != widget.user.email) {
                      return GestureDetector(
                        onTap: _follow,
                        child: Icon(
                          Icons.person_add_alt_1_rounded,
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: _unfollow,
                      child: Icon(
                        Icons.person,
                        color: Colors.green[600],
                      ),
                    );
                  }),
              SizedBox(
                width: 8.0,
              ),
              widget.document['likedUsers']?.contains(widget.user.email) ??
                      false
                  ? GestureDetector(
                      onTap: _unlike,
                      child: Icon(
                        Icons.local_fire_department,
                        color: Colors.red,
                      ),
                    )
                  : GestureDetector(
                      onTap: _like,
                      child: Icon(Icons.local_fire_department),
                    ),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.blue[600],
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          RelayPage(widget.document, widget.user)));
                },
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 3),
        ),
        Image.network(
          widget.document['photoUrl'],
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        // ListTile(
        Container(
          // leading: Row(
          //   mainAxisSize: MainAxisSize.min,
          //   children: <Widget>[
          //     widget.document['likedUsers']?.contains(widget.user.email) ??
          //             false
          //         ? GestureDetector(
          //             onTap: _unlike,
          //             child: Icon(
          //               Icons.local_fire_department,
          //               color: Colors.red,
          //             ),
          //           )
          //         : GestureDetector(
          //             onTap: _like,
          //             child: Icon(Icons.local_fire_department),
          //           ),
          //     SizedBox(
          //       width: 8.0,
          //     ),
          //     // Icon(Icons.comment),
          //     SizedBox(
          //       width: 8.0,
          //     ),
          //     // Icon(Icons.send),
          //   ],
          // ),
          // trailing: Icon(Icons.bookmark_border),
          padding: EdgeInsets.only(bottom: 13),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              '응원해요 ${widget.document['likedUsers']?.length ?? 0}개  |  릴레이 ${widget.document['relayCount'] ?? 0}개',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
            ),
            SizedBox(
              width: 16.0,
            ),
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          children: <Widget>[
            SizedBox(
              width: 16.0,
            ),
            // Text(
            //   widget.document['email'],
            //   style: TextStyle(fontWeight: FontWeight.bold),
            // ),
            // SizedBox(
            //   width: 8.0,
            // ),
            Text(
              widget.document['contents'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        if (commentCount > 0)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentPage(widget.document),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        '응원 $commentCount개 모두 보기',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  Text(widget.document['lastComment'] ?? ''),
                ],
              ),
            ),
          ),
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextField(
                  controller: _commentController,
                  onSubmitted: (text) {
                    _writeComment(text);
                    _commentController.text = '';
                  },
                  decoration: InputDecoration(
                    hintText: '한마디 남기기',
                  ),
                ),
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }

  // 좋아요
  void _like() {
    //기존 좋아요 복사
    final List likedUsers =
        List<String>.from(widget.document['likedUsers'] ?? []);
    //나를 추가
    likedUsers.add(widget.user.email);

    //업데이트할 항목을 문서로 준비
    final updateData = {
      'likedUsers': likedUsers,
    };

    Firestore.instance
        .collection('post')
        .document(widget.document.documentID)
        .updateData(updateData);
  }

  // 좋아요 취소
  void _unlike() {
    //기존 좋아요 복사
    final List likedUsers =
        List<String>.from(widget.document['likedUsers'] ?? []);
    //나를 뺀다
    likedUsers.remove(widget.user.email);

    //업데이트할 항목을 문서로 준비
    final updateData = {
      'likedUsers': likedUsers,
    };

    Firestore.instance
        .collection('post')
        .document(widget.document.documentID)
        .updateData(updateData);
  }

  // 댓글 작성
  void _writeComment(String text) {
    final data = {
      'writer': widget.user.displayName,
      'email' : widget.user.email,
      'comment': text,
    };
    //댓글 추가
    Firestore.instance
        .collection('post')
        .document(widget.document.documentID)
        .collection('comment')
        .add(data);

    final updateData = {
      'lastComment': text,
      'commentCount': (widget.document['commentCount'] ?? 0) + 1,
    };

    Firestore.instance
        .collection('post')
        .document(widget.document.documentID)
        .updateData(updateData);
  }

  // 팔로우
  void _follow() {
    Firestore.instance
        .collection('following')
        .document(widget.user.email)
        .setData({widget.document['email']: true}, merge: true);
    Firestore.instance
        .collection('follower')
        .document(widget.document['email'])
        .setData({widget.user.email: true}, merge: true);
  }

  // 언팔로우
  void _unfollow() {
    Firestore.instance
        .collection('following')
        .document(widget.user.email)
        .setData({widget.document['email']: false}, merge: true);
    Firestore.instance
        .collection('follower')
        .document(widget.document['email'])
        .setData({widget.user.email: false}, merge: true);
  }

  // 팔로잉 상태를 얻는 스트림
  Stream<DocumentSnapshot> _followingStream() {
    return Firestore.instance
        .collection('following')
        .document(widget.user.email)
        .snapshots();
  }
}
