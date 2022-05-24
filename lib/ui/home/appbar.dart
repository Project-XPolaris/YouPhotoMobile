import 'package:flutter/material.dart';

renderHomeAppBar(BuildContext context){
  return AppBar(
    title: Text("YouPhoto"),
    elevation: 0,
    actions: [
      IconButton(onPressed: (){
      }, icon: Icon(Icons.search,color: Colors.white,)
      )
    ],
  );
}