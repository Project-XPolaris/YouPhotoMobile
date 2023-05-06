import 'package:flutter/material.dart';

ScrollController createLoadMoreController(Function onLoadMore,{delta = 225}){
  ScrollController _controller = ScrollController();
  _controller.addListener(() {
    var maxScroll = _controller.position.maxScrollExtent;
    var pixel = _controller.position.pixels;
    if ((maxScroll - pixel) < delta ) {
      onLoadMore();
    } else {}
  });
  return _controller;
}