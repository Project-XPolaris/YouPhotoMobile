import 'package:flutter/material.dart';

renderHomeAppBar(BuildContext context){
  return AppBar(
    title: const Text("YouPhoto"),
    elevation: 0,
    actions: [
      IconButton(onPressed: (){
      }, icon: const Icon(Icons.search,color: Colors.white,)
      )
    ],
  );
}