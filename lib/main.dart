import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

void main() => runApp(AppCotacao());

class AppCotacao extends StatelessWidget {
  static const String _title = 'Cotações';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: CotacoesWidget(),
      ),
    );
  }
}

class CotacoesWidget extends StatefulWidget {
  @override
  _CotacoesWidgetState createState() => _CotacoesWidgetState();
}

class _CotacoesWidgetState extends State<CotacoesWidget> {
  List<dynamic> _moedas = List<dynamic>();
  String _dataCarregamento = '';

  @override
  void initState() {
    onButtonPressCotacoes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _moedas.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == _moedas.length) {
              return Container(
                child: Column(children: <Widget>[
                  Text(_dataCarregamento),
                  FlatButton(
                    child: Text("Atualizar"),
                    onPressed: onButtonPressCotacoes,
                  )
                ]),
              );
            }
            return Container(
                height: 50,
                child: MoedaWidget(
                    code: _moedas[index]["code"],
                    name: _moedas[index]["name"],
                    high: double.parse(_moedas[index]["high"]),
                    low: double.parse(_moedas[index]["low"])));
          }),
    );
  }

  onButtonPressCotacoes() async {
    // Realizando Request
    String url = 'https://economia.awesomeapi.com.br/json/all';
    Response response = await get(url);
    // Capturando Response
    String content = response.body;

    if (response.statusCode == 200) {
      print('Response body : ${content}');
      try {
        final parsed = jsonDecode(content).cast<String, dynamic>();
        setState(() {
          _moedas.clear();
          parsed.keys.forEach((code) {
            _moedas.add(parsed[code]);
          });
          _dataCarregamento = 'Atualizado em ' +
              new DateFormat('dd/MM/yyyy HH:mm:ss')
                  .format(new DateTime.now().toLocal());
        });
      } catch (Ex) {
        print("Erro ao decodificar JSON : $Ex");
      }
    }
  }
}

class MoedaWidget extends StatelessWidget {
  MoedaWidget({Key key, this.code, this.name, this.high, this.low})
      : super(key: key);

  final String code;
  final String name;
  final double high;
  final double low;

  final numberFormatter = new NumberFormat("#,##0.00#", "pt_BR");

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              const SizedBox(width: 10),
              Expanded(child: Text('${this.code} - ${this.name}')),
              Icon(Icons.arrow_drop_up, color: Colors.red),
              Text('R\$ ${this.numberFormatter.format(this.high)}'),
              const SizedBox(width: 10),
              Icon(Icons.arrow_drop_down, color: Colors.green),
              Text('R\$ ${this.numberFormatter.format(this.low)}'),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}
