import 'package:emprestimo_obj/view/lista_emprestimo.dart';

class Emprestimo {
  int _tipoObj;
  String _nomeEmprestado;
  String _descricaoObj;
  DateTime _dtEmprestimo;
  bool _devolvido;

  Emprestimo(this._tipoObj, this._nomeEmprestado, this._descricaoObj,
      this._dtEmprestimo, this._devolvido);

  int get getTipoObj => _tipoObj;
  bool get getConcluida => _devolvido;
  String get getNome => _nomeEmprestado;
  String get getDescricaoObj => _descricaoObj;
  DateTime get getDtEmprestimo => _dtEmprestimo;

  Map getEmprestimo() {
    Map<String, dynamic> emprestimo = Map();
    emprestimo["nome de quem pegou"] = _nomeEmprestado;
    emprestimo["devolvido"] = _devolvido;
    emprestimo["descricao"] = _descricaoObj;
    emprestimo["data do emprestimo"] = _dtEmprestimo;
    emprestimo["tipo"] = _tipoObj;
    return emprestimo;
  }
}
