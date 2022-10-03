import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

main() {
  runApp(MyWidget());
}

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  var player;
  List tune = [];
  List<Duration> duration=[];
  List<List> AllDurations=[];
  List<List> AllTunes = [];
  List<PopupMenuItem> items = [];
  bool isRecording = false;
  var S;
  int j = 0;

  @override
  void initState() {
    player = new AudioPlayer();
    S=Stopwatch();
  }

  Widget MusicButton(color, int i) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          player.play("lib/Music/note$i.wav", isLocal: true);
          if (isRecording) {
            S.stop();
            duration.add(S.elapsed);
            tune.add(i);
            S.reset();
            S.start();
          }
        },
        child: null,
        style: ButtonStyle(backgroundColor: color),
      ),
    );
  }

  Widget ActionButton(icon, function, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: IconButton(
          tooltip: hint,
          onPressed: function,
          icon: Icon(
            icon,
            color: Colors.red,
          )),
    );
  }

  void play(int index) async {
    for (int i = 0; i < AllTunes[index].length; i++) {
      await player.play("lib/Music/note${AllTunes[index][i]}.wav",
          isLocal: true);
      if(i<AllTunes[index].length-1)
        await Future.delayed(AllDurations[index][i]);
    }
  }

  void popupmenuitem() {
    int k = AllTunes.length - 1;
    items.add(PopupMenuItem(
      value: k,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              play(k);
            },
            icon: Icon(
              Icons.play_arrow,
              color: Colors.green,
            ),
            tooltip: "Play",
          ),
          IconButton(
            onPressed: () {
              setState(() {
                if (j > k) {
                  items.removeAt(k);
                  AllTunes.remove(k);
                } else {
                  items.removeLast();
                  AllTunes.removeLast();
                }
                j--;
              });
            },
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            tooltip: "Delete",
          ),
          Text(
            "Tune ${j + 1}",
            style: TextStyle(color: Colors.black),
          )
        ],
      ),
    ));
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            actions: [
              ActionButton(Icons.fiber_manual_record, () {
                isRecording = true;
                S.start();
                tune.clear();
                duration.clear();
              }, hint: "Record"),
              ActionButton(Icons.stop, () {
                isRecording = false;
                S.stop();
              }, hint: "Stop Recording"),
              ActionButton(Icons.save, () {
                //AllTunes.add(tune); it's a problem because it compare using the reference and we always use tune and this will make overriding ont the previous elements
                List l = [];
                l.addAll(tune);
                duration.removeAt(0);
                List d = [];
                d.addAll(duration);
                AllTunes.add(l);
                AllDurations.add(d);
                popupmenuitem();
                j++;

              }, hint: "Save"),
              ActionButton(Icons.delete, () {
                tune.clear();
                isRecording = false;
              }, hint: "Dispose"),
              PopupMenuButton(itemBuilder: (context) {
                return items;
              })
            ],
            title: Text(
              "Music App",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.black,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MusicButton(MaterialStateProperty.all(Colors.yellow), 1),
              MusicButton(MaterialStateProperty.all(Colors.red), 2),
              MusicButton(MaterialStateProperty.all(Colors.green), 3),
              MusicButton(MaterialStateProperty.all(Colors.purple), 4),
              MusicButton(MaterialStateProperty.all(Colors.deepOrange), 5),
              MusicButton(MaterialStateProperty.all(Colors.blue), 6),
              MusicButton(MaterialStateProperty.all(Colors.pink), 7)
            ],
          ),
        ));
  }
}
