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
  Map<String, dynamic> _lastRemove = Map();
  int _lastRemovePos;

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

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDOList.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });

      _salveData();
    });

    return null;
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
              child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                      padding: EdgeInsets.only(top: 10.0),
                      itemCount: _toDOList.length,
                      // ignore: missing_return
                      itemBuilder: buildItem),
              ))
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime
          .now()
          .millisecondsSinceEpoch
          .toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      onDismissed: (direcao) {
        setState(() {
          _lastRemove = Map.from(_toDOList[index]);
          _lastRemovePos = index;
          _toDOList.removeAt(index);
          _salveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemove["titulo"]} \" removida "),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _toDOList.insert(_lastRemovePos, _lastRemove);
                  _salveData();
                });
              },
            ),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).showSnackBar(snack);
        });
      },
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDOList[index]["titulo"]),
        value: _toDOList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDOList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            _toDOList[index]["ok"] = c;
            _salveData();
          });
        },
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
