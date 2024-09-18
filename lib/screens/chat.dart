import 'package:alex_chat/widgits/chat_masseges.dart';
import 'package:alex_chat/widgits/new_massege.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class ChartScreen extends StatelessWidget{
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: const Text('alex chat'),
       actions: [
         IconButton(onPressed: (){
           FirebaseAuth.instance.signOut();
         }, icon: const Icon(Icons.exit_to_app),
           color: Theme.of(context).colorScheme.primary,)
       ],),
       body: const Column(children:[
         Expanded(child: ChatMessages(),),
         NewMessage(),

         ],)

     );

  }

}