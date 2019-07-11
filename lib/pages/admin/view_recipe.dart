import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart' as img;
import 'package:recipes/auth/auth.dart';
import 'package:recipes/model/recipe_model.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';


//create stf with the name ViewRecipe
class ViewRecipe extends StatefulWidget {
  ViewRecipe({this.recipe, this.idRecipe, this.uid});
  final String idRecipe;
  final String uid;
  final Recipe recipe;
  _ViewRecipeState createState() => _ViewRecipeState();
}

enum SelectSource { camara, galeria }

class _ViewRecipeState extends State<ViewRecipe> {
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
      shape: BoxShape.rectangle,
      image: DecorationImage(
          fit: BoxFit.fill, image: AssetImage('assets/images/azucar.gif')));

  
  @override
  void initState() {
    setState(() {
      this._name = widget.recipe.name;
      this._recipe = widget.recipe.recipe;
      captureImage(null, widget.recipe.image);
    });

    print('uid receta : ' + widget.idRecipe);
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
            shape: BoxShape.rectangle,
            image: DecorationImage(fit: BoxFit.fill, image: FileImage(_image)));
      });
    } else {
      print('descarga la imagen');
      _downloadFile(url, widget.recipe.name).then((onValue) {
        _image = onValue;
        setState(() {
          box = BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: Colors.white,
              image:
                  DecorationImage(fit: BoxFit.fill, image: FileImage(_image)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.black,
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                    offset: Offset(2.0, 10.0))
              ]);
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('View Recipe'),
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
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: GestureDetector(
                              onDoubleTap: getImage,
                            ),
                            margin: EdgeInsets.only(top: 10),
                            height: 250,
                            width: 330,
                            decoration: box,
                          )
                        ]),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                    ),
                    TextFormField(
                      enabled: false,
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
                      maxLines: 10,
                      enabled: false,
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
        );
  }
}
