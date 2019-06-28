import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipes/auth/auth.dart';


class RootPage extends StatefulWidget {

  RootPage({this.auth});
  final BaseAuth auth;
  _RootPageState createState() => _RootPageState();

}

enum AuthStatus { notSignIn, signIn }

class _RootPageState extends State<RootPage> {

  AuthStatus _authStatus = AuthStatus.notSignIn;

  @override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((onValue) {
      setState(() {
        print(onValue);
        _authStatus =
        onValue == 'no_login' ? AuthStatus.notSignIn : AuthStatus.signIn;
      });
    });
  }

  void _signIn() {
    setState(() {
      _authStatus = AuthStatus.signIn;
    });
  }

  void _signOut() {
    setState(() {
      _authStatus = AuthStatus.notSignIn;
    });
  }


  @override
  Widget build(BuildContext context) {
    Widget _widget;

    //Aqui si esta logeado lo lleva a la App HomePage sino lo lleva a login mas registro
    switch (_authStatus) {
      case AuthStatus.notSignIn:
      //return IntroScreen(auth: widget.auth,onSignIn: _signIn,);
      break;
      case AuthStatus.signIn:
        //return HomePage( auth: widget.auth,onSignedOut: _signOut,);//menu_page.dart
        break;
    }

    return _widget;
  } 
  }
