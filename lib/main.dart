import 'dart:convert';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Desafio Teia - Nelson Bordin',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(0, 92, 169, 0.9)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // var current = WordPair.random();

  // void getNext() {
  //   current = WordPair.random();
  //   notifyListeners();
  // }
  // var favorites = <WordPair>[];

  // void toggleFavorite() {
  //   if (favorites.contains(current)) {
  //     favorites.remove(current);
  //   } else {
  //     favorites.add(current);
  //   }
  //   notifyListeners();
  // }

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = ApelidoPage();
        break;
      case 1:
        page = JSONPlaceHolderPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Apelido'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('JSONPlaceHolder'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class ApelidoPage extends StatefulWidget {
  const ApelidoPage({super.key});

  @override
  State<ApelidoPage> createState() => _ApelidoPageState();
}

class _ApelidoPageState extends State<ApelidoPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))],
                decoration: InputDecoration(
                  hintText: 'Digite seu apelido com 3 até 20 caracteres',
                  border: OutlineInputBorder(),
                  labelText: 'apelido',
                ),
                controller: _controller,
                onSubmitted: (String value) async {
                  _handleSubmit(value);
                  },
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                _handleSubmit(_controller.text);
                
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
  void _handleSubmit(String value){
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        if (value.characters.length >= 3 && value.characters.length <= 20) {                  
          return AlertDialog(
            title: const Text('Apelido válido!'),
            content: Text(
                'Você digitou "$value", que possui ${value.characters.length} caracteres.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text('Apelido inválido!'),
            content: Text(
                'Você digitou "$value", que possui ${value.characters.length} caracteres.'
                ' Digite um apelido entre 3 e 20 caracteres.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        }
      },
    );
    _controller.clear();
  }
}


class JSONPlaceHolderPage extends StatefulWidget{
  @override
  State<JSONPlaceHolderPage> createState() => _JSONPlaceHolderPageState();
}

class _JSONPlaceHolderPageState extends State<JSONPlaceHolderPage> {
  List<Map<String, dynamic>> _data = [];

  void initState(){
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        _data = jsonData.map((item) => item as Map<String,dynamic>).toList();
      });
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: _data.isEmpty ? [] : _data.first.keys.map((String column)=> DataColumn(label: Text(column)))
          .toList(),
          rows: _data.isEmpty ? [] : _data.map((Map<String,dynamic> row) => DataRow(cells: row.keys.map((String key){
            return DataCell(Text('${row[key]}'));
          }).toList(),
          ))
          .toList()
        ),
      ),
    );
  }
}

// class GeneratorPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var appState = context.watch<MyAppState>();
//     var pair = appState.current;

//     IconData icon;
//     if (appState.favorites.contains(pair)) {
//       icon = Icons.favorite;
//     } else {
//       icon = Icons.favorite_border;
//     }

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           BigCard(pair: pair),
//           SizedBox(height: 10),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ElevatedButton.icon(
//                 onPressed: () {
//                   appState.toggleFavorite();
//                 },
//                 icon: Icon(icon),
//                 label: Text('Like'),
//               ),
//               SizedBox(width: 10),
//               ElevatedButton(
//                 onPressed: () {
//                   appState.getNext();
//                 },
//                 child: Text('Next'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      elevation: 9,
      color: theme.colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(pair.asLowerCase, 
        style: style,
        semanticsLabel: "${pair.first} ${pair.second}"
        ),
      ),
    );
  }
}

class ApelidoTextField extends StatefulWidget {
  const ApelidoTextField({super.key});

  @override
  State<ApelidoTextField> createState() => _ApelidoTextFieldState();
}

class _ApelidoTextFieldState extends State<ApelidoTextField> {
  @override
  
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 250,
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'apelido',
        ),
      ),
    );
  }
}



// void main() => runApp(const ApelidoApp());

// class ApelidoApp extends StatelessWidget {
//   const ApelidoApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: ApelidoTextField(),
//     );
//   }
// }

// class ApelidoTextField extends StatefulWidget {
//   const ApelidoTextField({super.key});

//   @override
//   State<ApelidoTextField> createState() => _ApelidoTextFieldState();
// }

// class _ApelidoTextFieldState extends State<ApelidoTextField> {
//   late TextEditingController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))],
//               decoration: InputDecoration(
//                 hintText: 'Digite seu apelido com 3 até 20 caracteres',
//                 border: OutlineInputBorder(),
//                 labelText: 'apelido',
//               ),
//               controller: _controller,
//               onSubmitted: (String value) async {
//                 _handleSubmit(value);
//                 },
//             ),
//             SizedBox(height: 20,),
//             ElevatedButton(
//               onPressed: () {
//                 _handleSubmit(_controller.text);
                
//               },
//               child: Text('Salvar'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   void _handleSubmit(String value){
//     showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         if (value.characters.length >= 3 && value.characters.length <= 20) {                  
//           return AlertDialog(
//             title: const Text('Apelido válido!'),
//             content: Text(
//                 'Você digitou "$value", que possui ${value.characters.length} caracteres.'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           );
//         } else {
//           return AlertDialog(
//             title: const Text('Apelido inválido!'),
//             content: Text(
//                 'Você digitou "$value", que possui ${value.characters.length} caracteres.'
//                 ' Digite um apelido entre 3 e 20 caracteres.'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           );
//         }
//       },
//     );
//     _controller.clear();
//   }
// }

