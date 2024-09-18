
import 'package:alex_chat/widgits/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget{
 const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  void setupPushNotification ()async{

    final fcm =FirebaseMessaging.instance;
    await fcm.requestPermission();
    // final token=await fcm.getToken();
    fcm.subscribeToTopic('chat');

  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final authenticationUser= FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore
            .instance.collection('chat')
            .orderBy(
          'createdAt',
          descending: true,
        )
            .snapshots(),
        builder: (cxt, chatSnapshots) {
      if(chatSnapshots.connectionState == ConnectionState.waiting){
        return const Center(child: CircularProgressIndicator(),);
      }
      if(!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty){
         return const Center(child: Text('no Messages'),);
      }
      if(chatSnapshots.hasError){
        return const Center(child: Text('ohhhhhhhhhh'),);
      }
      final loadedMessages=chatSnapshots.data!.docs;
      return ListView.builder(
        padding: const EdgeInsets.only(

          left: 13,
          right:13 ,
          bottom:40 ,


        ),
          reverse: true,

          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
          final chatMessages=loadedMessages[index].data();
          final nextChatMessages=index+1 < loadedMessages.length
          ? loadedMessages[index+1].data()
              :null;
          final currentMessagesUserId=chatMessages['userId'];
          final nextMessagesUserId=
              nextChatMessages != null ? nextChatMessages['userId']:null;
          final nextUserSame=nextMessagesUserId == currentMessagesUserId;
          if(nextUserSame){
            return MessageBubble.next(message: chatMessages['text'],
                isMe: authenticationUser.uid==currentMessagesUserId);
          }else{
            return MessageBubble.first(
                userImage: chatMessages['userImage'],
                username: chatMessages['username'],
                message: chatMessages['text'],
                isMe: authenticationUser.uid==currentMessagesUserId);
          }
          }

          );


        },);




  }
}