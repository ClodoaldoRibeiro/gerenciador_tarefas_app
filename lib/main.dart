import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

const CONS_COR = Colors.blueAccent;

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Gerenciador de Tarefas",
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDOList = [];

  final TextEditingController _novoTarefaontroller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _lerData().then((data) {
      setState(() {
        _toDOList = json.decode(data);
      });
    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDO = Map();
      newToDO["titulo"] = _novoTarefaontroller.text;
      _novoTarefaontroller.text = "";
      newToDO["ok"] = false;
      _toDOList.add(newToDO);
      _salveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lista de tarefas",
        ),
        backgroundColor: CONS_COR,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        labelText: "Nova tarefa",
                        labelStyle: TextStyle(color: CONS_COR)),
                    controller: _novoTarefaontroller,
                  ),
                ),
                RaisedButton(
                  color: CONS_COR,
                  textColor: Colors.white,
                  child: Text("ADD"),
                  onPressed: _addToDo,
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDOList.length,
                // ignore: missing_return
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(_toDOList[index]["titulo"]),
                    value: _toDOList[index]["ok"],
                    secondary: CircleAvatar(
                      child: Icon(
                          _toDOList[index]["ok"] ? Icons.check : Icons.error),
                    ),
                    onChanged: (c) {
                      setState(() {
                        _toDOList[index]["ok"] = c;
                        _salveData();
                      });
                    },
                  );
                }),
          )
        ],
      ),
    );
  }

  Future<File> _getData() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/data.json");
  }

  Future<File> _salveData() async {
    String data = json.encode(_toDOList);
    final file = await _getData();
    return file.writeAsString(data);
  }

  Future<String> _lerData() async {
    try {
      final file = await _getData();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
