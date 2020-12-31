import 'dart:io';

import 'package:chapter10/tab_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateRelayPage extends StatefulWidget {
  final FirebaseUser user;
  final DocumentSnapshot document;
  CreateRelayPage(this. document, this.user);

  @override
  _CreateRelayPageState createState() => _CreateRelayPageState();
}

class _CreateRelayPageState extends State<CreateRelayPage> {

  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getImage();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  File _image;
  File _video;

  // 갤러리에서 사진 가져오기
  Future _getImage() async {
    var image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 640,
      maxHeight: 480,
    );

    setState(() {
      _image = image;
    });
  }

  //갤러리에서 동영상 가져오기
  Future _getVideo() async {
    var video = await ImagePicker.pickVideo(
      source: ImageSource.gallery, //ImageSource.camera
    );

    setState(() {
      _video = video;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('새 게시물'),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            _uploadImage(context);
          },
          child: Text('공유'),
        )
      ],
    );
  }

  Future _uploadImage(BuildContext context) async {
    // 스토리지에 업로드할 파일 경로
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('post')
        .child('${DateTime
        .now()
        .millisecondsSinceEpoch}.png');

    // 파일 업로드
    final task = firebaseStorageRef.putFile(
      _image,
      StorageMetadata(contentType: 'image/png'),
    );
    // 완료까지 기다림
    final storageTaskSnapshot = await task.onComplete;
    // 업로드 완료 후 url
    final downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

    // 문서 작성
    await Firestore.instance
        .collection('post')
        .document(widget.document.documentID)
        .collection('relay')
        .add(
        {
          'contents' : textEditingController.text,
          'displayName' : widget.user.displayName,
          'email': widget.user.email,
          'photoUrl' : downloadUrl,
          'userPhotoUrl' : widget.user.photoUrl,
        }
    );

    Firestore.instance
        .collection('post')
        .document(widget.document.documentID)
        .updateData({
      'relayCount': (widget.document['relayCount'] ?? 0) + 1
    });

    // 완료 후 앞 화면으로 이동
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TabPage(widget.user),
        ));
  }

  Future _uploadVideo(BuildContext context) async {
    // 스토리지에 업로드할 파일 경로
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('post')
        .child('${DateTime
        .now()
        .millisecondsSinceEpoch}.mp4');

    // 파일 업로드
    final task = firebaseStorageRef.putFile(
      _video,
      StorageMetadata(contentType: 'video/mp4'),
    );
    // 완료까지 기다림
    final storageTaskSnapshot = await task.onComplete;
    // 업로드 완료 후 url
    final downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

    // 문서 작성
    await Firestore.instance
        .collection('post')
        .document(widget.document.documentID)
        .collection('relay')
        .add(
        {
          'contents' : textEditingController.text,
          'displayName' : widget.user.displayName,
          'email': widget.user.email,
          'videoUrl' : downloadUrl,
          'userPhotoUrl' : widget.user.photoUrl,
        }
    );

    // 완료 후 앞 화면으로 이동
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TabPage(widget.user),
        ));
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                _buildImage(),
                SizedBox(
                  width: 8.0,
                ),
                Expanded(
                  child: TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: '문구 입력...',
                    ),
                  ),
                )
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Text('사람 태그하기'),
          ),
          Divider(),
          ListTile(
            leading: Text('위치 추가하기'),
          ),
          Divider(),
          _buildLocation(),
          ListTile(
            leading: Text('위치 추가하기'),
          ),
          ListTile(
            leading: Text('Facebook'),
            trailing: Switch(
              value: false,
              onChanged: (bool value) {},
            ),
          ),
          ListTile(
            leading: Text('Twitter'),
            trailing: Switch(
              value: false,
              onChanged: (bool value) {},
            ),
          ),
          ListTile(
            leading: Text('Tumblr'),
            trailing: Switch(
              value: false,
              onChanged: (bool value) {},
            ),
          ),
          Divider(),
          ListTile(
            leading: Text(
              '고급 설정',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return _image == null
        ? Text('No Image')
        : Image.file(
      _image,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }

  Widget _buildLocation() {
    final locationItems = [
      '기흥 도서관',
      '경기도 용인시',
      '동백호수공원',
      '강남대학교',
      '신도림역',
      '검색',
    ];
    return SizedBox(
      height: 34.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: locationItems.map((location) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Chip(
              label: Text(
                location,
                style: TextStyle(fontSize: 12.0),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
