import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:recipes/auth/auth.dart'; 


class CommonThings {
  static Size size;
}

class MyAddRecipe extends StatefulWidget {

  final String id;
  const MyAddRecipe({this.id});


  @override
  _MyAddRecipeState createState() => _MyAddRecipeState();
}

enum SelectSource { camara, galeria }


class _MyAddRecipeState extends State<MyAddRecipe> {

  File _foto;
  String urlFoto;
  bool _isInAsyncCall = false;
  String recipes;
  Auth auth = Auth();


  TextEditingController recipeInputController;
  TextEditingController nameInputController;
  TextEditingController imageInputController;

  String id;
  final db = Firestore.instance;
  final _formKey = GlobalKey<FormState>();
  String name;
  String uid;
  String recipe;
  String usuario;

  Future captureImage(SelectSource opcion) async {
    File image;

    opcion == SelectSource.camara
        ? image = await ImagePicker.pickImage(source: ImageSource.camera)
        : image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _foto = image;
    });
  }

  Future getImage() async {
    AlertDialog alerta = new AlertDialog(
      content: Text('Seleccione de donde desea capturar la imagen'),
      title: Text('Seleccione Imagen'),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            // seleccion = SelectSource.camara;
            captureImage(SelectSource.camara);
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Row(
            children: <Widget>[Text('Camara'), Icon(Icons.camera)],
          ),
        ),
        FlatButton(
          onPressed: () {
            // seleccion = SelectSource.galeria;
            captureImage(SelectSource.galeria);
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Row(
            children: <Widget>[Text('Galeria'), Icon(Icons.image)],
          ),
        )
      ],
    );
    showDialog(context: context, child: alerta);
  }



  Widget divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Container(
        width: 0.8,
        color: Colors.black,
      ),
    );
  }



  bool _validarlo(){
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _enviar() {
    if (_validarlo()) {
      setState(() {
        _isInAsyncCall = true;
      });
      auth.currentUser().then((onValue) {
        setState(() {
          usuario = onValue;
        });
        if (_foto != null) {
          final StorageReference fireStoreRef = FirebaseStorage.instance
              .ref()
              .child('usuarios')
              .child(usuario)
              .child('mycolrecipes')
              .child('$name.jpg');
          final StorageUploadTask task = fireStoreRef.putFile(
              _foto, StorageMetadata(contentType: 'image/jpeg'));
          task.onComplete.then((onValue) {
            onValue.ref.getDownloadURL().then((onValue) {
              setState(() {
                urlFoto = onValue.toString();
                Firestore.instance
                    .collection('usuarios')
                    .document(usuario)
                    .collection('mycolrecipes')
                    .add({
                      'name': name,
                      'image': urlFoto,
                      'recipe': recipe,
                    })
                    .then((value) => Navigator.of(context).pop())
                    .catchError((onError) =>
                        print('Error al registrar su receta bd'));
                _isInAsyncCall = false;
              });
            });
          });
        } else {
          Firestore.instance
              .collection('usuarios')
              .document(usuario)
              .collection('mycolrecipes')
              .add({
                'name': name,
                'image': urlFoto,
                'recipe': recipe,
              })
              .then((value) => Navigator.of(context).pop())
              .catchError(
                  (onError) => print('Error al registrar su receta bd'));
          _isInAsyncCall = false;
        }
      }).catchError((onError) => _isInAsyncCall = false);

      //

    } else {
      print('objeto no validado');
    }
  }

  @override
  Widget build(BuildContext context) {
    CommonThings.size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add My Recipe'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isInAsyncCall,
        opacity: 0.5,
        dismissible: false,
        progressIndicator: CircularProgressIndicator(),
        color: Colors.blueGrey,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 10, right: 15),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: GestureDetector(
                        onTap: getImage,
                      ),
                      margin: EdgeInsets.only(top: 20),
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1.0, color: Colors.black),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: _foto == null
                                  ? AssetImage('assets/images/azucar.gif')
                                  : FileImage(_foto))),
                    )
                  ],
                ),
                Text('click para cambiar foto'),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'name',
                    fillColor: Colors.grey[300],
                    filled: true,
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                  },
                  onSaved: (value) => name = value.trim(),
                ),
                TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'recipe',
                    fillColor: Colors.grey[300],
                    filled: true,
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some recipe';
                    }
                  },
                  onSaved: (value) => recipe = value,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: _enviar,
                      child: Text('Create', style: TextStyle(color: Colors.white)),
                      color: Colors.green,
                    ),
                  ],)
              ],
            ),
          ),
        ),
      )
    );
  }
}