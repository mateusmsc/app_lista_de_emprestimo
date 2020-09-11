import 'dart:convert';
import 'package:emprestimo_obj/model/emprestimo.dart';
import 'package:emprestimo_obj/persitence/manipula_emp.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

enum TipoObj { livro, revista, jornal }

class _HomeState extends State<Home> {
  ManipulaEmprestimo manipulaArquivo = ManipulaEmprestimo();
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  Map<String, dynamic> _ultimoRemovido;
  int _ultimoRemovidoPos;
  List _emprestimoList = [];

  @override
  void initState() {
    super.initState();
    //manipulaArquivo.saveEmprestimo([]);
    manipulaArquivo.readEmprestimo().then((dado) {
      setState(() {
        _emprestimoList = json.decode(dado);
      });
    });
  }

  void _addEmprestimo() {
    setState(() {
      Map<String, dynamic> novoEmprestimo = Map();
      Emprestimo emprestimo = Emprestimo(_character, _nomeController.text,
          _descController.text, _dataInfo, false);
      novoEmprestimo = emprestimo.getEmprestimo();
      _nomeController.text = "";
      _descController.text = "";
      _emprestimoList.add(novoEmprestimo);
      manipulaArquivo.saveEmprestimo(_emprestimoList);
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _emprestimoList.sort((a, b) {
        if (a["concluida"] && !b["concluida"])
          return 1;
        else if (!a["concluida"] && b["concluida"])
          return -1;
        else
          return 0;
      });
      manipulaArquivo.saveEmprestimo(_emprestimoList);
    });
    return null;
  }

  DateTime _dataInfo = DateTime.now();
  int _character = TipoObj.livro.index;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text("Lista de Empréstimos"),
          centerTitle: true,
        ),
        body: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          ListTile(
            title: const Text('Revista'),
            leading: Radio(
              value: TipoObj.revista.index,
              groupValue: _character,
              onChanged: (int value) {
                setState(() {
                  _character = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Jornal'),
            leading: Radio(
              value: TipoObj.jornal.index,
              groupValue: _character,
              onChanged: (int value) {
                setState(() {
                  _character = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Livro'),
            leading: Radio(
              value: TipoObj.livro.index,
              groupValue: _character,
              onChanged: (int value) {
                setState(() {
                  _character = value;
                });
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(labelText: "Seu nome"),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _descController,
                    decoration:
                        InputDecoration(labelText: "Descrição do produto"),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: FlatButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    "${_dataInfo}",
                    style: TextStyle(color: Colors.amber[900]),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: Colors.amber[900],
                  ),
                ],
              ),
              onPressed: () async {
                final dataSelecionada = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1967),
                  lastDate: DateTime(2050),
                  builder: (BuildContext context, Widget child) {
                    return Theme(
                      data: ThemeData.dark(),
                      child: child,
                    );
                  },
                );
                if (dataSelecionada != null && dataSelecionada != _dataInfo) {
                  setState(() {
                    _dataInfo = dataSelecionada as DateTime;
                  });
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 5),
            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
            height: 50.0,
            width: double.infinity,
            child: RaisedButton(
              child: Text("Adicionar empréstimo"),
              textColor: Colors.white,
              onPressed: () {
                _addEmprestimo();
              },
              color: Colors.amber[900],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _emprestimoList.length,
                  itemBuilder: buildItem),
            ),
          ),
        ]));
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_emprestimoList[index]["nome de quem pegou"]),
        value: _emprestimoList[index]["devolvido"],
        secondary: CircleAvatar(
          child: Icon(
              _emprestimoList[index]["devolvido"] ? Icons.check : Icons.add),
        ),
        onChanged: (c) {
          setState(() {
            _emprestimoList[index]["devolvido"] = c;
            manipulaArquivo.saveEmprestimo(_emprestimoList);
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _ultimoRemovido = Map.from(_emprestimoList[index]);
          _ultimoRemovidoPos = index;
          _emprestimoList.removeAt(index);
          manipulaArquivo.saveEmprestimo(_emprestimoList);
          final snack = SnackBar(
            content:
                Text("Emprestimo \"${_ultimoRemovido["descricao"]}\"removido!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _emprestimoList.insert(_ultimoRemovidoPos, _ultimoRemovido);
                    manipulaArquivo.saveEmprestimo(_emprestimoList);
                  });
                }),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }
}
