import 'package:async/async.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

//Without timer and dialogs
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
  List<Icon> row = [];
  var bank;
  bool isNotLoading = false; //api
  bool Finish = false;
  List Current_Answers = [];
  late RestartableTimer T;

  void initState() {
    //api
    //always work like this when you use api
    bank = new QuestionBank();
    T = RestartableTimer(Duration(seconds: 100), () {
      setState(() {
        Finish = true;
      });
    });
    bank.Multiple_Choice_Question().then((value) => setState(() {
      isNotLoading = value;
      Current_Answers = bank.Get_All_Answers();
    }));
  }

  Widget alert(BuildContext context) {
    if (bank.index == 20)
      return AlertDialog(
        title: Text(
          "End of exam",
          style: TextStyle(color: Colors.blue),
        ),
        titlePadding: EdgeInsets.symmetric(horizontal: 200, vertical: 20),
        content: RichText(
          text: TextSpan(
              text:
              "You have Answered all questions , the number of correct answers ",
              children: [
                TextSpan(
                    text: "${bank.NumOfCorrectAnswers}",
                    style: TextStyle(color: Colors.green, fontSize: 20)),
                TextSpan(text: " , the number of incorrect answers "),
                TextSpan(
                    text: "${bank.NumOfIncorrectAnswers}",
                    style: TextStyle(color: Colors.red, fontSize: 20)),
                TextSpan(text: " , your result is "),
                TextSpan(
                    text: "${bank.NumOfCorrectAnswers * 100 ~/ 20}%",
                    style: TextStyle(color: Colors.deepOrange, fontSize: 20))
              ]),
        ),
        // "You have Answered ${bank.index} questions , the number of correct answers ${bank.NumOfCorrectAnswers} , the number of incorrect answers ${bank.NumOfInorrectAnswers} , your result is ${bank.NumOfCorrectAnswers * 100 ~/ bank.index}%"
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  Finish = false;
                  bank.Restart();
                  Current_Answers = bank.Get_All_Answers();
                  row.clear();
                  T.reset();
                });
              },
              child: Text("Restart")),
        ],
      );
    else
      return AlertDialog(
        title: Text(
          "Time Out",
          style: TextStyle(color: Colors.red),
        ),
        titlePadding: EdgeInsets.symmetric(horizontal: 165, vertical: 20),
        content: RichText(
          text: TextSpan(text: "You have Answered ", children: [
            TextSpan(
                text: "${bank.index}",
                style: TextStyle(color: Colors.blue, fontSize: 20)),
            TextSpan(text: " questions , the number of correct answers "),
            TextSpan(
                text: "${bank.NumOfCorrectAnswers}",
                style: TextStyle(color: Colors.green, fontSize: 20)),
            TextSpan(text: " , the number of incorrect answers "),
            TextSpan(
                text: "${bank.NumOfIncorrectAnswers}",
                style: TextStyle(color: Colors.red, fontSize: 20)),
            TextSpan(text: " , your result is "),
            TextSpan(
                text: "${bank.NumOfCorrectAnswers * 100 ~/ 20}%",
                style: TextStyle(color: Colors.deepOrange, fontSize: 20))
          ]),
        ),
        // "You have Answered ${bank.index} questions , the number of correct answers ${bank.NumOfCorrectAnswers} , the number of incorrect answers ${bank.NumOfInorrectAnswers} , your result is ${bank.NumOfCorrectAnswers * 100 ~/ bank.index}%"
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  Finish = false;
                  bank.Restart();
                  Current_Answers = bank.Get_All_Answers();
                  row.clear();
                  T.reset();
                });
              },
              child: Text("Restart")),
        ],
      );
  }

  Widget Chip(String a, String b) {
    return ActionChip(
        backgroundColor: Colors.green,
        avatar: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(a),
        ),
        label: Text(b),
        onPressed: () {
          setState(() {
            if (bank.index == 20)
              Finish = true;
            else {
              if (bank.Get_Correct_Answer() == b) {
                bank.NumOfCorrectAnswers++;
                row.add(Icon(
                  Icons.check,
                  color: Colors.green,
                ));
              } else {
                bank.NumOfIncorrectAnswers++;
                row.add(Icon(
                  Icons.clear,
                  color: Colors.red,
                ));
              }
              bank.Next_Question();
              Current_Answers = bank.Get_All_Answers();
            }
          });
        });
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          //api
          body: isNotLoading
              ? (Finish
              ? alert(context)
              : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  bank.Get_Question()!,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip('A', Current_Answers[0]),
                    SizedBox(
                      height: 20,
                    ),
                    Chip('B', Current_Answers[1]),
                    SizedBox(
                      height: 20,
                    ),
                    Chip('C', Current_Answers[2]),
                    SizedBox(
                      height: 20,
                    ),
                    Chip('D', Current_Answers[3]),
                    SizedBox(
                      height: 16,
                    ),
                    Wrap(
                      children: row,
                    )
                  ],
                ),
              )
            ],
          ))
              : Center(
            child: CircularProgressIndicator(),
          ),
        ));
  }
}

//api
//model file
class Multiple_Choice {
  String? question;
  String? CorrectAnswer;
  List IncorrectAnswer;
  Multiple_Choice(this.question, this.CorrectAnswer, this.IncorrectAnswer);

  factory Multiple_Choice.convert(Map<String, dynamic> json) {
    String q = json['question'];
    q=q.replaceAll(RegExp(r'&quot;'),"'");
    q=q.replaceAll(RegExp(r'&#039;'),"'");
    String CA = json['correct_answer'];
    List IA = [];
    IA.addAll(json['incorrect_answers']);
    return Multiple_Choice(q, CA, IA);
  }

  @override
  String toString() {
    return "question : $question , correct_answer:$CorrectAnswer , incorrect_answers:$IncorrectAnswer";
  }
}

//utils file
class QuestionBank {
  List<Multiple_Choice> questions = [];
  int index = 0;
  int NumOfCorrectAnswers = 0;
  int NumOfIncorrectAnswers = 0;
  QuestionBank() {}

  //api
  //services file
  Future<bool> Multiple_Choice_Question() async {
    var response = await get(Uri.tryParse(
        "https://opentdb.com/api.php?amount=21&category=18&type=multiple")!);
    Map<String, dynamic> json = jsonDecode(response.body);
    if (response.statusCode != 200)
      throw new Exception("error in connection");
    else {
      for (int i = 0; i < 21; i++)
        questions.add(Multiple_Choice.convert(json['results'][i]));
      questions.shuffle();
    }
    return true;
  }

  void Next_Question() {
    index++;
  }

  void Restart() {
    index = 0;
    NumOfCorrectAnswers = 0;
    NumOfIncorrectAnswers = 0;
    questions.shuffle();
  }

  String? Get_Question() {
    return questions[index].question;
  }

  String? Get_Correct_Answer() {
    return questions[index].CorrectAnswer;
  }

  List Get_All_Answers() {
    List l = [questions[index].CorrectAnswer];
    l.addAll(questions[index].IncorrectAnswer);
    l.shuffle();
    return l;
  }
}
