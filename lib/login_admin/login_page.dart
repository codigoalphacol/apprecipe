import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipes/auth/auth.dart';
import 'package:recipes/login_admin/menu_page.dart';
import 'package:recipes/model/user_model.dart';


class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.onSignIn});

  final BaseAuth auth;
  final VoidCallback onSignIn;

  @override
  _LoginPageState createState() => _LoginPageState();
}

enum FormType { login, registro }
enum SelectSource { camara, galeria }

class _LoginPageState extends State<LoginPage> {

  final formKey = GlobalKey<FormState>();
  //Declaramos las variables
  String _email;
  String _password;
  String _nombre;
  String _telefono;
  String _itemCiudad;
  String _direccion;
  String _urlFoto = '';
  String usuario;


  bool _obscureText = true;
  FormType _formType = FormType.login;
  List<DropdownMenuItem<String>> _ciudadItems;//list city from Firestore


  @override
  void initState() {
    super.initState();
    setState(() {
      _ciudadItems = getCiudadItems();
      _itemCiudad = _ciudadItems[0].value;
    });
  }

   getData() async {
    return await Firestore.instance.collection('ciudades').getDocuments();
  }

  //Dropdownlist from firestore
   List<DropdownMenuItem<String>> getCiudadItems() {
    List<DropdownMenuItem<String>> items = List();
    QuerySnapshot dataCiudades;
    getData().then((data) {

      dataCiudades = data;
      dataCiudades.documents.forEach((obj) {
        print('${obj.documentID} ${obj['nombre']}');
        items.add(DropdownMenuItem(
          value: obj.documentID,
          child: Text(obj['nombre']),
        ));
      });
    }).catchError((error) => print('hay un error.....' + error));

    items.add(DropdownMenuItem(
      value: '0',
      child: Text('- Seleccione -'),
    ));

    return items;
  }


  bool _validarGuardar() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  //we create a method validate and send
  void _validarEnviar() async {
    if (_validarGuardar()) {
      try {
        String userId = await widget.auth.signInEmailPassword(_email, _password);
        print('Usuario logueado : $userId ');//ok 
        widget.onSignIn();
        HomePage(auth: widget.auth);  //return menu_page.dart
        Navigator.of(context).pop();     
      } catch (e) {
        print('Error .... $e');
        AlertDialog alerta = new AlertDialog(
          content: Text('Error en la Autenticación'),
          title: Text('Error'),
          actions: <Widget>[],
        );
        showDialog(context: context, child: alerta);
      }
    }
  }

  //Now create a method validate and register
  void _validarRegistrar() async {
    if (_validarGuardar()) {
      try{
        Usuario usuario = Usuario(//model/user_model.dart instance usuario
            nombre: _nombre,
            ciudad: _itemCiudad,
            direccion: _direccion,
            email: _email,
            password: _password,
            telefono: _telefono,
            foto: _urlFoto);
        String userId = await widget.auth.signUpEmailPassword(usuario);
        print('Usuario logueado : $userId');//ok
        widget.onSignIn();
        HomePage(auth: widget.auth);  //menu_page.dart
        Navigator.of(context).pop(); 
      }catch (e){
        print('Error .... $e');
        AlertDialog alerta = new AlertDialog(
          content: Text('Error en el registro'),
          title: Text('Error'),
          actions: <Widget>[],
        );
        showDialog(context: context, child: alerta);
      }
    }
  }
  //method go register
  void _irRegistro() {
    setState(() {
      formKey.currentState.reset();
      _formType = FormType.registro;
    });
  }

  //method go Login
  void _irLogin() {
    setState(() {
      formKey.currentState.reset();
      _formType = FormType.login;
    });
  }

  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes'),
      ),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
              padding: EdgeInsets.all(16.0),
              child: Center(
                  child: Form(
                    key: formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .stretch, //ajusta los widgets a lso extremos
                        children: [
                          Padding(padding: EdgeInsets.only(top: 15.0)),
                          Text(
                            'Recetas Mundiales \n Mis recetas',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17.0,
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 15.0)),
                        ] +
                            buildInputs() +
                            buildSubmitButtons()),
                  )))
                  ),
    );
  }

List<Widget> buildInputs() {
    if (_formType == FormType.login) {
      return [ //list or array
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            icon: Icon(FontAwesomeIcons.envelope),
          ),
          validator: (value) =>
          value.isEmpty ? 'El campo Email está vacio' : null,
          onSaved: (value) => _email = value.trim(),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
        ),
        TextFormField(
          keyboardType: TextInputType.text,
          obscureText: _obscureText,
          decoration: InputDecoration(
              labelText: 'Contraseña',
              icon: Icon(FontAwesomeIcons.key),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
              )
          ),
          validator: (value) => value.isEmpty
              ? 'El campo password debe tener\nal menos 6 caracteres'
              : null,
          onSaved: (value) => _password = value.trim(),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
        ),
      ];
    } else {
      return [
        Row(mainAxisAlignment: MainAxisAlignment.center,),           
        Text('Registro Usuario', style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),),
        TextFormField(
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              labelText: 'Nombre', icon: Icon(FontAwesomeIcons.user)),
          validator: (value) =>
          value.isEmpty ? 'El campo Nombre esta vacio' : null,
          onSaved: (value) => _nombre = value.trim(),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
        ),
        TextFormField(
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Celular',
            icon: Icon(FontAwesomeIcons.phone),
          ),
          validator: (value) =>
          value.isEmpty ? 'El campo Telefono esta vacio' : null,
          onSaved: (value) => _telefono = value.trim(),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
        ),
        DropdownButtonFormField(
          validator: (value) =>
          value == '0' ? 'Debe seleccionar una ciudad' : null,
          decoration: InputDecoration(
              labelText: 'Ciudad', icon: Icon(FontAwesomeIcons.city)),
          value: _itemCiudad,
          items: _ciudadItems,
          onChanged: (value) {
            setState(() {
              _itemCiudad = value;
            });
          }, //seleccionarCiudadItem,
          onSaved: (value) => _itemCiudad = value,
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
        ),
        TextFormField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Dirección',
              icon: Icon(Icons.person_pin_circle),
            ),
            validator: (value) =>
            value.isEmpty ? 'El campo Direccion está vacio' : null,
            onSaved: (value) => _direccion = value.trim()),
        Padding(
          padding: EdgeInsets.all(8.0),
        ),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            icon: Icon(FontAwesomeIcons.envelope),
          ),
          validator: (value) =>
          value.isEmpty ? 'El campo Email esta vacio' : null,
          onSaved: (value) => _email = value.trim(),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
        ),
        TextFormField(
          obscureText: _obscureText,//password
          decoration: InputDecoration(
              labelText: 'Contraseña',
              icon: Icon(FontAwesomeIcons.key),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
              )),
          validator: (value) => value.isEmpty
              ? 'El campo password debe tener\nal menos 6 caracteres'
              : null,
          onSaved: (value) => _password = value.trim(),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
        ),
      ];
    }
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        RaisedButton(
         onPressed: _validarEnviar,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Ingresar",
                style: TextStyle(color: Colors.white, fontSize: 15.0),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
              ),
              Icon(
                FontAwesomeIcons.checkCircle,
                color: Colors.white,
              )
            ],
          ),
          color: Colors.orangeAccent,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
          ),
          elevation: 8.0,
        ),
        FlatButton(
          child: Text(
            'Crear una cuenta',//create new acount
            style: TextStyle(fontSize: 20.0, color: Colors.grey),
          ),
          onPressed: _irRegistro,
        ),
      ];
    } else {
      return [
        RaisedButton(
          onPressed:  _validarRegistrar,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Registrar Cuenta",//register new acount
                style: TextStyle(color: Colors.white, fontSize: 15.0),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
              ),
              Icon(
                FontAwesomeIcons.plusCircle,
                color: Colors.white,
              )
            ],
          ),
          color: Colors.orangeAccent,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
          ),
          elevation: 8.0,
        ),
        FlatButton(
          child: Text(
            '¿Ya tienes una Cuenta?',
            style: TextStyle(fontSize: 20.0, color: Colors.grey),
          ),
          onPressed: _irLogin,
        )
      ];
    }
  }
}
