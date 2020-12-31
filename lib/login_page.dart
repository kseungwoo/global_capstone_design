import 'dart:async';

import 'package:chapter10/root_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'tab_page.dart';

class LoginPage extends StatelessWidget {
  //구글 로그인을 위한 객체
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 파이어베이스 인증 정보를 가지는 객체
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.ac_unit,size: 59,color: Colors.blueAccent,),
            Container(
              margin: EdgeInsets.all(15.0),
            ),
            Text(
              'FYLR',
              style: GoogleFonts.chivo(
                fontSize: 50.0,
              ),
            ),
            Container(
              margin: EdgeInsets.all(20.0),
            ),
            Text(
              'For Your Long Run\n',
              style: GoogleFonts.chivo(
                fontSize: 15.0,
              ),
            ),
            Container(
              margin: EdgeInsets.all(20.0),
            ),
            SignInButton(
              Buttons.Google,
              onPressed: () {
                _handleSignIn();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<FirebaseUser> _handleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = (await _auth.signInWithCredential(
            GoogleAuthProvider.getCredential(
                idToken: googleAuth.idToken,
                accessToken: googleAuth.accessToken)))
        .user;
    print("signed in " + user.displayName);
    return user;
  }
}
