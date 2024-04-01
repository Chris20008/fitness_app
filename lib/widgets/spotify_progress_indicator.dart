import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import '../main.dart';

class SpotifyProgressIndicator extends StatefulWidget {
  PlayerState? data;
  SpotifyProgressIndicator({super.key, this.data});

  @override
  State<SpotifyProgressIndicator> createState() => _SpotifyProgressIndicatorState();
}

class _SpotifyProgressIndicatorState extends State<SpotifyProgressIndicator> {
  bool doRefresh = true;

  // @override
  // void initState() {
  //   refresh();
  //   super.initState();
  // }
  //
  // @override
  // void dispose() {
  //   doRefresh = false;
  //   super.dispose();
  // }
  //
  // void refresh(){
  //   Future.delayed(const Duration(milliseconds: 200), (){
  //     if (doRefresh) {
  //       setState(() {});
  //       refresh();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {


    return LayoutBuilder(
      builder: (context, constraints){

        Widget child = const SizedBox();
        if (widget.data != null) {
          double width = widget.data!.playbackPosition / widget.data!.track!.duration * constraints.maxWidth;
          child = Container(
            height: 1,
            width: width,
            color: Colors.amber[800],
          );
        }

        return Container(
          height: 1,
          width: constraints.maxWidth,
          color: Colors.grey[350],
          child: Align(
            alignment: Alignment.centerLeft,
            child: child,
          ),
        );

        // return Consumer<PlayerStateStream>(
        //     builder: (context, playerStateStream, _) {
        //       return StreamBuilder(
        //           stream: playerStateStream.stream,
        //           builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
        //             Widget child = const SizedBox();
        //             if (snapshot.data != null) {
        //               double width = snapshot.data!.playbackPosition / snapshot.data!.track!.duration * constraints.maxWidth;
        //               child = Container(
        //                 height: 1,
        //                 width: width,
        //                 color: Colors.amber[800],
        //               );
        //             }
        //             return Container(
        //               height: 1,
        //               width: constraints.maxWidth,
        //               color: Colors.grey[350],
        //               child: Align(
        //                 alignment: Alignment.centerLeft,
        //                 child: child,
        //               ),
        //             );
        //           });
        //     });

          // child: StreamBuilder(
          //     stream: SpotifySdk.subscribePlayerState(),
          //     builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
          //       Widget child = const SizedBox();
          //       if (snapshot.data != null) {
          //         double width = snapshot.data!.playbackPosition / snapshot.data!.track!.duration * constraints.maxWidth;
          //         child = Container(
          //           height: 1,
          //           width: width,
          //           color: Colors.amber[800],
          //         );
          //       }
          //       return Container(
          //         height: 1,
          //         width: constraints.maxWidth,
          //         color: Colors.grey[350],
          //         child: Align(
          //           alignment: Alignment.centerLeft,
          //           child: child,
          //         ),
          //       );
          //     }
          // ),
        // );
      }
    );
  }
}