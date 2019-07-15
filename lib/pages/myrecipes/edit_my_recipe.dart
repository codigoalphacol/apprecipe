import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipes/auth/auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recipes/model/recipe_model.dart';


class EditMyRecipe extends StatefulWidget {

  EditMyRecipe({this.recipe, this.idRecipe, this.uid});
  final String idRecipe;
  final String uid;
  final Recipe recipe;//model/

  @override
  _EditMyRecipeState createState() => _EditMyRecipeState();
}


enum SelectSource { camara, galeria }


class _EditMyRecipeState extends State<EditMyRecipe> {

  final formKey = GlobalKey<FormState>();
  String _name;
  String _recipe;
  File _image; //
  String urlFoto = '';
  Auth auth = Auth();
  bool _isInAsyncCall = false;
  String usuario;
 
  BoxDecoration box = BoxDecoration(
                            border: Border.all(width: 1.0, color: Colors.black),
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image:AssetImage('assets/images/azucar.gif') ));

  @override
  void initState() {
    setState(() {
      this._name = widget.recipe.name;
      this._recipe = widget.recipe.recipe;      
      captureImage(null, widget.recipe.image);
    });

print('uid receta : '+widget.idRecipe);
    super.initState();
  }

  static var httpClient = new HttpClient();
  Future<File> _downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  
  
  Future captureImage(SelectSource opcion, String url) async {
    File image;
    if (url == null) {
      print('imagen');
      opcion == SelectSource.camara
          ? image = await img.ImagePicker.pickImage(
              source: img.ImageSource.camera) //source: ImageSource.camera)
          : image =
              await img.ImagePicker.pickImage(source: img.ImageSource.gallery);

      setState(() {
        _image = image;
        box = BoxDecoration(
                            border: Border.all(width: 1.0, color: Colors.black),
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image:FileImage(_image) ));

      });
    } else {
      print('descarga la imagen');
      _downloadFile(url, widget.recipe.name).then((onValue) {
        _image = onValue;
        setState(() {
          box = BoxDecoration(
                            border: Border.all(width: 1.0, color: Colors.black),
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image:FileImage(_image) ));
                 ////  imageReceta = FileImage(_foto);
                });
       
      // : FileImage(_imagen)))
     
      });
    }
  }

  Future getImage() async {
    AlertDialog alerta = new AlertDialog(
      content: Text('Seleccione para capturar la imagen'),
      title: Text('Seleccione Imagen'),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            // seleccion = SelectSource.camara;
            captureImage(SelectSource.camara, null);
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Row(
            children: <Widget>[Text('Camara'), Icon(Icons.camera)],
          ),
        ),
        FlatButton(
          onPressed: () {
            // seleccion = SelectSource.galeria;
            captureImage(SelectSource.galeria, null);
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



  bool _validar() {
    final form = formKey.currentState; 
      if (form.validate()) {
        form.save();
        return true;
      }    
    return false;
  }

  void _enviar() {
    if (_validar()) {
      setState(() {
        _isInAsyncCall = true;
      });
      auth.currentUser().then((onValue) {
        setState(() {
          usuario = onValue;
        });
        if (_image != null) {
          final StorageReference fireStoreRef = FirebaseStorage.instance
              .ref()
              .child('mycolrecipes')
              .child('$_name.jpg');
          final StorageUploadTask task = fireStoreRef.putFile(
              _image, StorageMetadata(contentType: 'image/jpeg'));

          task.onComplete.then((onValue) {
            onValue.ref.getDownloadURL().then((onValue) {
              setState(() {
                urlFoto = onValue.toString();
                Firestore.instance
                    .collection('usuarios')
                    .document(usuario)
                    .collection('mycolrecipes')
                    .document(widget.idRecipe).updateData({
                      'name': _name,
                      'image': urlFoto,
                      'recipe': _recipe,                      
                    }).then((value) => Navigator.of(context).pop())
                    .catchError((onError) =>
                        print('Error al editar la receta en la bd'));
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
                'name': _name,
                'image': urlFoto,
                'recipe': _recipe
              })
              .then((value) => Navigator.of(context).pop())
              .catchError(
                  (onError) => print('Error editar el usuario en la bd'));
          _isInAsyncCall = false;
        }
      }).catchError((onError) => _isInAsyncCall = false);
    } else {
      print('objeto no validado');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My edit recipe'),
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
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: <
                        Widget>[
                      Container(
                        child: GestureDetector(
                          onDoubleTap: getImage,
                        ),
                        margin: EdgeInsets.only(top: 20),
                        height: 120,
                        width: 120,
                        decoration: box
                      )
                    ]),
                    Text('Doble click para cambiar imagen'),
                   
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      initialValue: _name,
                      decoration: InputDecoration(
                          labelText: 'Name',
                         ),
                      validator: (value) =>
                          value.isEmpty ? 'El campo Nombre esta vacio' : null,
                      onSaved: (value) => _name = value.trim(),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      initialValue: _recipe,
                      decoration: InputDecoration(
                          labelText: 'Recipe',
                         ),
                      validator: (value) =>
                          value.isEmpty ? 'El campo Nombre esta vacio' : null,
                      onSaved: (value) => _recipe = value.trim(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                    )
                  ],
                ),
              ),
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.orange,
            onPressed: _enviar,
            child: Icon(Icons.edit)),
        bottomNavigationBar: BottomAppBar(
          elevation: 20.0,
          color: Colors.blue,
          child: ButtonBar(),
        ));
  }
}
