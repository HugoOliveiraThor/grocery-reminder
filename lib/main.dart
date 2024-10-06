import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
   final TextEditingController _latController = TextEditingController(text: '-15.8122093');
   final TextEditingController _longController = TextEditingController(text: '-48.0229043');   

  String _currentLat = '';
  String _currentLong = '';
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _getCurrentLocation(); 
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  Future<void> _getCurrentLocation() async {
    // Verifica a permissão de localização
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      // Obtém a localização atual
      try {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        
        // Atualiza a latitude e longitude atuais
        setState(() {
          _currentLat = position.latitude.toString();
          _currentLong = position.longitude.toString();
        });
      } catch (e) {
        print('Erro ao obter a localização: $e');
        setState(() {
          _currentLat = 'Erro ao obter';
          _currentLong = 'Erro ao obter';
        });
      }
    } else {
      print('Permissão de localização negada.');
      setState(() {
        _currentLat = 'Permissão negada';
        _currentLong = 'Permissão negada';
      });
    }
  }
  Future<void> _checkLocationAndNotify() async {
    double latitude = double.tryParse(_latController.text) ?? 0;
    double longitude = double.tryParse(_longController.text) ?? 0;

    // Obtém a localização atual novamente
    await _getCurrentLocation();

    // Verifica a permissão de localização
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      // Obtém a localização atual
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // Atualiza a latitude e longitude atuais
      setState(() {
        _currentLat = position.latitude.toString();
        _currentLong = position.longitude.toString();
      });
      print(_currentLat);
      print(_currentLong);
      // Verifica se a localização atual está dentro de um pequeno intervalo da latitude e longitude fornecidas
      if ((position.latitude - latitude).abs() < 0.001 && (position.longitude - longitude).abs() < 0.001) {
        _showNotification();
      } else {
        print('Você não está na localização desejada.');
      }
      // Atualiza os campos com os valores mais recentes
      _latController.text = _currentLat;
      _longController.text = _currentLong;
    } else {
      print('Permissão de localização negada.');
    }
  }    

  void _incrementCounter() {
    setState(() {
      // _counter++;
    });
    _showNotification(); // Chama a função de notificação ao incrementar
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await flutterLocalNotificationsPlugin.show(
      0,
      'Localizacao disparada',
      'Localizacao correta mesmo local',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child:Padding(padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _longController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _latController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _checkLocationAndNotify,
              child: const Text('Verificar Localização'),
            ),
            const SizedBox(height: 20),
              // Exibindo a latitude e longitude atuais
              Text('Sua Latitude: $_currentLat'),
              Text('Sua Longitude: $_currentLong'),
          ],
        ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
