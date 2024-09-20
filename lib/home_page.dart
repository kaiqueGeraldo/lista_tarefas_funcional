import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  List _listarTarefas = [];
  Map<String, dynamic> _ultimaTarefaRemovida = {};

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File('${diretorio.path}/dados.json');
  }

  _adicionarTarefa() {
    String textDigitado = _controller.text;

    Map<String, dynamic> tarefa = {};
    tarefa['titulo'] = textDigitado;
    tarefa['realizada'] = false;

    setState(() {
      _listarTarefas.add(tarefa);
    });
    _salvarArquivo();
    _controller.text = '';
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();

    String dados = json.encode(_listarTarefas);
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();

      if (await arquivo.exists()) {
        String conteudo = await arquivo.readAsString();

        if (conteudo.isNotEmpty) {
          return conteudo;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    _lerArquivo().then((dados) {
      if (dados != null) {
        setState(() {
          _listarTarefas = json.decode(dados);
        });
      }
    });
  }

  Widget criarItemLista(context, index) {

    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _ultimaTarefaRemovida = _listarTarefas[index];
        _listarTarefas.removeAt(index);
        _salvarArquivo();

        var snackBar = SnackBar(
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                setState(() {
                  _listarTarefas.insert(index, _ultimaTarefaRemovida);
                });
                _salvarArquivo();
              },
            ),
            content: const Text(
              'Tarefa Removida!',
              style: TextStyle(fontSize: 20),
            ));

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      background: Container(
          color: Colors.red,
          child: const Padding(
            padding: EdgeInsets.only(right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  size: 40,
                  Icons.delete,
                  color: Colors.white,
                ),
              ],
            ),
          )),
      child: CheckboxListTile(
        title: Text(
          _listarTarefas[index]['titulo'],
          style: const TextStyle(fontSize: 20),
        ),
        value: _listarTarefas[index]['realizada'],
        onChanged: (valorAlterado) {
          setState(() {
            _listarTarefas[index]['realizada'] = valorAlterado;
          });
          _salvarArquivo();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _listarTarefas.length,
              itemBuilder: criarItemLista,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Adicionar Tarefa'),
              content: TextField(
                controller: _controller,
                autofocus: true,
                onSubmitted: (value) {
                  _adicionarTarefa();
                  Navigator.pop(context);
                },
                decoration: const InputDecoration(
                  label: Text(
                    'Digite alguma tarefa',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    _adicionarTarefa();
                    Navigator.pop(context);
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
