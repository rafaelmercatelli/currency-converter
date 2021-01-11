import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

const request = "https://api.hgbrasil.com/finance/quotations?key=abc0bde0";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double cotacaoDolar;
  double cotacaoEuro;

  //final é importante por algum motivo!!!
  final realControler = TextEditingController();
  final dolarControler = TextEditingController();
  final euroControler = TextEditingController();

  void _clearAll(){
    realControler.text = "";
    dolarControler.text = "";
    euroControler.text = "";
  }

  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarControler.text = (real/cotacaoDolar).toStringAsFixed(2);
    euroControler.text = (real/cotacaoEuro).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realControler.text = (dolar * this.cotacaoDolar).toStringAsFixed(2);
    euroControler.text = (dolar * this.cotacaoDolar / cotacaoEuro).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realControler.text = (euro * this.cotacaoEuro).toStringAsFixed(2);
    dolarControler.text = (euro * this.cotacaoEuro / cotacaoDolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Conversor de moedas"),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      //Map pois Jason é um mapa
      body: FutureBuilder<Map>(
        //passando o mapa pelo getData (json)
        future: getData(),
        //snapshot para ver a conexão e contem os dados
        builder: (context, snapshot) {
          //fazendo um switch para analisar como a conexão esta. none ou waiting
          // carrega um load. caso error mensagem de erro e else continua o codigo
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados, aguarde...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.00),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar dados!",
                    style: TextStyle(color: Colors.amber, fontSize: 25.00),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                cotacaoDolar =
                    snapshot.data["results"]["currencies"]["USD"]["buy"];
                cotacaoEuro =
                    snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.monetization_on,
                          size: 150.0, color: Colors.amber),
                      buildTextField(
                          "Reais", "R\$", realControler, _realChanged),
                      Divider(),
                      buildTextField(
                          "Dólares", "US\$", dolarControler, _dolarChanged),
                      Divider(),
                      buildTextField(
                          "Euros", "€\$", euroControler, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  //json.decode transfomra o body do response em um mapa
  return json.decode(response.body);
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function funcao) {
  return TextField(
    controller: controller,
    onChanged: funcao,
    keyboardType: TextInputType.number,
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
  );
}

