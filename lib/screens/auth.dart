import 'package:alex_chat/widgits/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

//Firebase authentication instance
final _fireBase=FirebaseAuth.instance;



class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  File? _selectedImage;
  var userCredentials;
  var _isLogin = true;
  var _enteredEmail = '';
  var _username='';
    var _enteredPassword = '';
    var _isAuthenticate=false;
    //submission method for sign up and sign in
  void _submit()async {
    final isValid = _form.currentState!.validate();

    if(!isValid || ! _isLogin && _selectedImage==null){
      return;
    }


      _form.currentState!.save();
    try{
      setState(() {
        _isAuthenticate=true;
      });
      //check for sign up or sign in
       if(_isLogin){
         //submission method for sign in
          userCredentials=await _fireBase.signInWithEmailAndPassword(
             email: _enteredEmail, password: _enteredPassword);


       }else{
         //submission method for sign up
            userCredentials=await _fireBase.
           createUserWithEmailAndPassword(email: _enteredEmail, password: _enteredPassword);
           final storageRef= FirebaseStorage.instance
               .ref().child('user_images')
               .child('${userCredentials
               .user!.uid}.jpg');
           await storageRef.putFile(_selectedImage!);
           final imageUrl=await storageRef.getDownloadURL();
           await FirebaseFirestore
                .instance
                .collection('users')
                .doc(userCredentials
                .user!.uid).set({
             'username': _username,
             'email': _enteredEmail,
             'image_url': imageUrl
           });

       }

         }on FirebaseAuthException catch(erorr){
           if(erorr.code=='email-already-in-use'){

           }
           ScaffoldMessenger.of(context).clearSnackBars();
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
               content:Text(erorr.message??'killed') )

           );
           setState(() {
             _isAuthenticate=false;
           });


       }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin:const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                    child: Padding(
                      padding:const EdgeInsets.all(16),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if(!_isLogin)
                              UserImagePicker(onPickImage: (pickedImage) {
                                _selectedImage=pickedImage;
                              },),
                            TextFormField(
                              decoration:const InputDecoration(
                                label: Text('Email'),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'please use @ and make sure ';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                            ),
                            if(!_isLogin)
                            TextFormField(
                              decoration:const InputDecoration(
                                label: Text('username'),
                              ),

                            enableSuggestions: false,
                              validator: (value) {
                                if (value == null ||value.isEmpty|| value.trim().length < 4) {
                                  return 'username has to be 4 ';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _username = value!;
                              },
                            ),
                            TextFormField(
                              decoration:const InputDecoration(
                                label: Text('password'),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'password has to be 6 ';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredPassword = value!;
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            if(_isAuthenticate)
                              const CircularProgressIndicator(),
                            if(!_isAuthenticate)
                            ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                child: Text(_isLogin ? 'login' : 'sign up')),
                            if(!_isAuthenticate)
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? 'create Account'
                                    : 'I already have an account')),
                          ],
                        ),
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
