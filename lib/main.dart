import 'dart:async';
import 'package:flutter/foundation.dart';
//import 'package:flutter/services.dart';
//import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'dart:io';
import 'dart:ui';
//import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:flutter_vlc_player/vlc_player.dart';
import 'package:flutter_vlc_player/vlc_player_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';

class MachineID {//設定機台ID資料架構
  final String title;
  final String description;

  MachineID(this.title, this.description);
}

final int machineamount = 1;//機台總數量

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {//APP本體
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData(
        primaryColor:Colors.green[800],
      ),
      debugShowCheckedModeBanner: false,
      title: 'VendingMAapp',
      initialRoute: '/',
      routes: {//頁面命名
        '/': (context) => HomeScreen(),
        '/first': (context) => FirstScreen(
          IDs: List.generate(
            machineamount,
                (i) => MachineID(
              'MachineID $i',
              'A description of what needs to be done for MachineID $i',
            ),
          ),
        ),
        //'/detail':(context) => DetailScreen(),
        '/preplay': (context) => PrepareScreen(),
        '/second': (context) => preSecondScreen(storage: GameStorage()),
        '/third': (context) => ThirdScreen(),
        '/forth': (context) => ForthScreen(),
      },//home: MyApp()
    );
  }
}

class HomeScreen extends StatelessWidget {//首頁
  @override

  Widget build(BuildContext context) {
    //BuildContext tests = context;
    Widget titleSection = Container(
      child: Center(
        child:(
            Text(
              '無接觸經濟\n智慧聯網販賣機',//智慧聯網
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w600,
                color: Colors.green[600],
              ),
            )
        ),
      ),
    );

    Widget buttonSection = Container(//配置按鈕
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //margin: const EdgeInsets.only(top: 8),
        children: [
          _buildButtonColumn(Colors.lightGreen[500], '啟動',context),
          _buildButtonColumn(Colors.lightGreen[500], '使用紀錄',context),
          _buildButtonColumn(Colors.lightGreen[500], '設定',context),
          _buildButtonColumn(Colors.lightGreen[500], '說明',context),
          _buildButtonColumn(Colors.lightGreen[500], '離開',context),
        ],
      ),
    );

    return Scaffold(//首頁介面設定
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('VendingMAapp',
        ),
      ),
      body: ListView(
        children: [
          AspectRatio(  //設定圖片的長寬比
            aspectRatio: 18.0 / 14.0,
            child: Image.asset(
              'images/LOGO3.png',
            ),
          ),
          titleSection,
          buttonSection,
          //textSection,
        ],
      ),
    );
  }

  Column _buildButtonColumn(Color color, String label,BuildContext contex) {//按鈕製造公式
    String orderstr;
    switch(label){
      case '啟動':
        orderstr = '/first';
        break;
      case '使用紀錄':
        orderstr = '/second';
        break;
      case '說明':
        orderstr = '/third';
        break;
      case '設定':
        orderstr = '/forth';
        break;
    }
    //判斷式，離開按鈕要單獨特別設計
    if (label == '離開'){
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 25),
            child:FlatButton(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              onPressed: ()=> exit(0),
              color: color,
            ),
          ),
        ],
      );
    }

    else{//離開以外的按鈕
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 25),
            child:FlatButton(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(contex, orderstr);
              },
              color: color,
            ),
          ),
        ],
      );
    }
  }
}

// ignore: must_be_immutable
class FirstScreen extends StatefulWidget {//選擇機台頁面
  List<MachineID> IDs;
  FirstScreen({Key key, @required this.IDs}) : super(key: key);

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {

  String barcode = '';
  Future _scan() async {//QRCODE掃描
    BuildContext context;
    barcode = await scanner.scan();
  }

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('啟動'),
        elevation:  4.0,
        actions: <Widget>[
          IconButton(
              icon: Icon(MdiIcons.qrcodeScan),
              onPressed: () {
                _scan();//進入掃描QRCODE模式，有時間的話改為跳說明視窗？？
                if (barcode == '1'){
                  print(barcode);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrepareScreen(ID: widget.IDs[0]),
                    ),
                  );
                }
              }
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body:ListView.builder(//用清單展示
        itemCount: widget.IDs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.IDs[index].title),
            onTap: () {
              if (index == 0){
                GameStorage().cleanfile();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrepareScreen(ID: widget.IDs[index]),
                  ),
                );
              }
              else{
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(ID: widget.IDs[index]),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class GameStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/gamelist.txt');
  }

  Future<List<String>> readCounter() async {
    List<String> lines = [];
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsStringSync();
      lines = contents.split("\n");
      print(lines);

      return lines;
    } catch (e) {
      // If encountering an error, return 0
      return ['0'];
    }
  }

  Future<File> writeCounter(var now) async {
    final file = await _localFile;
    print(file);

    print('$now'+'\n');
    // Write the file
    return file.writeAsString('$now'+'\n');
  }

  Future<Null> writeFile(String text) async {
    final file = await _localFile;

    IOSink sink = file.openWrite(mode: FileMode.append);
    sink.add(utf8.encode('$text\n')); //Use newline as the delimiter
    await sink.flush();
    await sink.close();
  }

  Future<File> cleanfile() async {
    final file = await _localFile;
    print(file);

    return file.writeAsString('');
  }

}

class PrepareScreen extends StatefulWidget{//我也不知道(X
  final MachineID ID;

  PrepareScreen({Key key, @required this.ID}) : super(key: key);
  @override
  Gamingscreen createState() => Gamingscreen();
}

/*class dynamicDisplay extends StatelessWidget {
  final String inputs;
  dynamicDisplay(this.inputs);

  String input = 'Please press buttoms to input.';

  Future<Text> inputString() async {
    return Text(
      input,
      style: TextStyle(height: 4, fontSize: 30),
    );
  }

  Widget dynamicInput(BuildContext context, int inputNum) {
    return Container(
      child: (
          input == null? Text(
            'input',
            style: TextStyle(height: 4, fontSize: 30),
          )
              :Text(
            input,
            style: TextStyle(height: 4, fontSize: 10),
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: _buildProductItem,
    );
  }
}*/

class Gamingscreen extends State<PrepareScreen> {//遊玩頁面

  String _streamUrl = 'http://192.168.1.183:8080/?action=stream';
  VlcPlayerController _vlcViewController;
  bool newStatus = false;

  void toggleSwitch(switchStatus) {
    var client = http.Client();
    try {
      var url = 'http://192.168.1.183:8080/?action=stream';//http://192.168.137.94:8080/stream_simple.html
      client.post(url, body: json.encode({'status': newStatus}),
          headers: {'Content-type': 'application/json'}).then((response) {
        print('status: ${newStatus.toString()}');
      });
    }
    finally {
      client.close();
    }
    setState(() {
      newStatus = !newStatus;
    });
  }
  void initState() {
    // TODO: implement initState
    super.initState();
    _vlcViewController = new VlcPlayerController();
  }

  Future<void> _sendingData(int data) async {   //負責傳送指令數字

    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
        .then((RawDatagramSocket socket) {
      int port = 5004;
      socket.send(data.toString().codeUnits,
          InternetAddress("192.168.1.183"), port);
    });
    //自己寫的

    /*var multicastEndpoint =
    Endpoint.multicast(InternetAddress("192.168.1.183"), port: Port(5004));
    var sender = await UDP.bind(Endpoint.any());
    await sender.send(data.toString().codeUnits, multicastEndpoint);
    await Future.delayed(Duration(seconds:5));
    sender.close();*/
    //套件的寫法
  }

  /*Future<Column> texttest() async {
    return Column(
      children: [
        Row(
          children: [
            Container(//該物件導向化了，把面板寫成外接程式碼
              width: 10,
              height: 5,
              child: TextField(
                obscureText: true,
                maxLength: 4,//最大长度，设置此项会让TextField右下角有一个输入数量的统计字符串
                maxLines: 1,//最大行数
                /*style: TextStyle(
                                      fontSize: 40.0,
                                      height: 2.0,
                                      color: Colors.black
                                  ),*/
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Pass',
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            _machineButtons(7),
            _machineButtons(8),
            _machineButtons(9),
          ],
        ),
        Row(
          children: [
            _machineButtons(4),
            _machineButtons(5),
            _machineButtons(6),
          ],
        ),
        Row(
          children: [
            _machineButtons(1),
            _machineButtons(2),
            _machineButtons(3),
          ],
        ),
        Row(
          children: [
            _machineButtons(11),
            _machineButtons(0),
            _machineButtons(12),
          ],
        ),
      ],
    );
  }*/


  Future<File> _moneyIn() async {   //判斷投錢，轉成指令數字
    int money = 10;
    _sendingData(money);
    var now = new DateTime.now();
    print(now);
    //GameStorage().writeCounter(now.toString());
    return GameStorage().writeFile(now.toString());
  }

  IconButton _machineButtons(int num){ //製作販賣機數字介面按鈕
    IconData iconKinds;
    switch(num){
      case 0:
        iconKinds = MdiIcons.numeric0Circle;
        break;
      case 1:
        iconKinds = MdiIcons.numeric1Circle;
        break;
      case 2:
        iconKinds = MdiIcons.numeric2Circle;
        break;
      case 3:
        iconKinds = MdiIcons.numeric3Circle;
        break;
      case 4:
        iconKinds = MdiIcons.numeric4Circle;
        break;
      case 5:
        iconKinds = MdiIcons.numeric5Circle;
        break;
      case 6:
        iconKinds = MdiIcons.numeric6Circle;
        break;
      case 7:
        iconKinds = MdiIcons.numeric7Circle;
        break;
      case 8:
        iconKinds = MdiIcons.numeric8Circle;
        break;
      case 9:
        iconKinds = MdiIcons.numeric9Circle;
        break;
      case 11:
        iconKinds = Icons.close;
        break;
      case 12:
        iconKinds = Icons.check;
        break;
    }

    if (num == 11){
      return IconButton(
        icon: Icon(iconKinds),
        iconSize: 37,
        onPressed: (){
          print("*WHERE IS MY MONEY*");
          _sendingData(num);
          //input = 'Please press \nbuttoms to input.';
        },
      );
    }
    else if (num ==12){
      return IconButton(
        icon: Icon(iconKinds),
        iconSize: 37,
        onPressed: (){
          print("*GIVE ME DRINK*");
          _sendingData(num);
          //input = 'Please press \nbuttoms to input.';
        },
      );
    }
    else{
      return IconButton(
        icon: Icon(iconKinds),
        iconSize: 37,
        onPressed: (){
          print("*"+ (num.toString())*3+ "*");
          _sendingData(num);
          //input = 'Please press \nbuttoms to input.';
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ID.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              new VlcPlayer(
                defaultHeight: 960,
                defaultWidth: 1280,
                url: _streamUrl,
                controller: _vlcViewController,
                placeholder: Container(),
              ),
            ],
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(35.0),//手機35.0，模擬器?
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 18), //手機18
                  ),
                  IconButton(
                    icon: Icon(Icons.local_atm,size: 50.0,),
                    onPressed: (){
                      print("*MONEY IN*");
                      _moneyIn();
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 60),// 手機60
                  ),
                  Column(
                    children: [
                      /*Row(
                        children: [
                          Container(//該物件導向化了，把面板寫成外接程式碼
                            child: TextField(
                              obscureText: true,
                              maxLength: 4,//最大长度，设置此项会让TextField右下角有一个输入数量的统计字符串
                              maxLines: 1,//最大行数
                              /*style: TextStyle(
                                      fontSize: 40.0,
                                      height: 2.0,
                                      color: Colors.black
                                  ),*/
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Pass',
                              ),
                            ),
                          ),
                        ],
                      ),*/
                      Row(
                        children: [
                          _machineButtons(7),
                          _machineButtons(8),
                          _machineButtons(9),
                        ],
                      ),
                      Row(
                        children: [
                          _machineButtons(4),
                          _machineButtons(5),
                          _machineButtons(6),
                        ],
                      ),
                      Row(
                        children: [
                          _machineButtons(1),
                          _machineButtons(2),
                          _machineButtons(3),
                        ],
                      ),
                      Row(
                        children: [
                          _machineButtons(11),
                          _machineButtons(0),
                          _machineButtons(12),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {//測試清單展示
  final MachineID ID;
  DetailScreen({Key key, @required this.ID}) : super(key: key);
  @override

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(ID.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(ID.description),
      ),
    );
  }
}

class preSecondScreen extends StatefulWidget {
  final GameStorage storage;

  preSecondScreen({Key key, @required this.storage}) : super(key: key);

  @override
  SecondScreen createState() => SecondScreen();
}

class SecondScreen extends State<preSecondScreen> {//使用紀錄頁面(未完成)
  @override

  List<String> timenow = ['JJ'];


  void initState() {
    super.initState();
    widget.storage.readCounter().then((List<String> value) async {
      setState(() {
        print(value);
        timenow = value;
      });
    });
  }

  Widget build(BuildContext context) {  //只顯示最後10個，但檔案還是要保留之前的

    return Scaffold(
      appBar: AppBar(
        title: Text("使用紀錄"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: DataTable(
              sortColumnIndex: 0,
              sortAscending: true,
              columns: [//第一列
                DataColumn(label: Text('日期')),
                DataColumn(label: Text('機台名稱')),
                DataColumn(label: Text('機台ID')),
              ],
              rows: [
                DataRow(
                  selected: false,
                  cells: [//第二列
                    DataCell(Text(timenow[0].toString())),
                    DataCell(Text('貓咪吊飾')),
                    DataCell(Text('0')),
                  ],
                ),
                DataRow(
                  selected: false,
                  cells: [//第三列
                    DataCell(Text(timenow[1].toString())),
                    DataCell(Text('美妝用品')),
                    DataCell(Text('1')),
                  ],
                ),
                DataRow(
                  selected: false,
                  cells: [//第四列
                    DataCell(Text(timenow[2].toString())),
                    DataCell(Text('電競滑鼠')),
                    DataCell(Text('2')),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(30.0),
            child:Center(
              child: RaisedButton(//返回鈕
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('返回'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThirdScreen extends StatelessWidget {//使用說明頁面，排版排很久QQ
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("使用說明"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Text('\n使用說明',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[600],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(32),
                child:Text(
                  '        本應用程式提供使用者能操作「無接觸經濟智慧聯網販賣機」以及查看歷史使用紀錄。\n\n'
                      '．遊玩「無接觸經濟智慧聯網販賣機」\n'
                      '        1.點擊「啟動按鈕」。\n'
                      '        2.直接選擇「機台名稱」。\n'//2.直接選擇「機台名稱」，或點擊右上角\n          「QR Code圖示」掃描QR Code。\n
                      '        3.跳轉至指定機台的操作頁面。\n'
                      '        4.點擊機台的「投幣符號」進行\n           投幣。\n'
                      '        5.在右半邊的數字面板按下想要\n           商品的編號。\n'
                      '        6.按下面板右下角的「確認符號\n           」。\n'
                      '        7.若欲再次選購，可直接點擊投\n           幣符號再次選購！\n\n'
                      '．查看歷史紀錄\n'
                      '        1.點擊「使用紀錄按鈕」。\n'
                      '        2.進入歷史紀錄顯示頁面，可查\n           看連接過的機台名稱、購買商\n           品名以及其連接日期時間。\n\n'
                      '．離開\n'
                      '        1.點擊「離開按鈕」。\n'
                      '        2.APP關閉。'
                  /*'        感謝使用！'*/,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              Container(
                //padding: const EdgeInsets.all(28.0),
                child:Center(
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('返回'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum Payment { LINEPay, ApplePay, Block, ATM, CreditCard }//設定支付方式名稱
enum Transport { FamilyMart, SevenEleven, BlackCat }//設定運送方式名稱

class ForthScreen extends StatefulWidget {//設定頁面
  ForthScreen({Key key}) : super(key: key);
  @override
  PaymentaskedState createState() => PaymentaskedState();
}

class PaymentaskedState extends State<ForthScreen> {//頁面實作

  /*String _value = '';
  String _value2 = '';
  void _setValue(String value) => setState(() => _value = value);
  void _setValue2(String value2) => setState(() => _value2 = value2);*/
  Payment payment = Payment.LINEPay;//支付預設LINEPAY
  Transport transport = Transport.BlackCat;//運送預設黑貓
  Color btncolor = Colors.lime;

  Future<void> _askedPayment() async {//未來建構式
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(//支付選項對話窗
            title: const Text('選擇支付方式'),
            children: <Widget>[
              ListTile(
                title: const Text('LINEPay'),
                leading: Radio(
                  value: Payment.LINEPay,
                  groupValue: payment,
                  activeColor: btncolor,
                  onChanged: (Payment value) {
                    setState(() {
                      payment = value;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('ApplePay'),
                leading: Radio(
                  value: Payment.ApplePay,
                  groupValue: payment,
                  activeColor: btncolor,
                  onChanged: (Payment value) {
                    setState(() {
                      payment = value;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('街口支付'),
                leading: Radio(
                  value: Payment.Block,
                  groupValue: payment,
                  activeColor: btncolor,
                  onChanged: (Payment value) {
                    setState(() {
                      payment = value;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('ATM轉帳'),
                leading: Radio(
                  value: Payment.ATM,
                  groupValue: payment,
                  activeColor: btncolor,
                  onChanged: (Payment value) {
                    setState(() {
                      payment = value;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('信用卡'),
                leading: Radio(
                  value: Payment.CreditCard,
                  groupValue: payment,
                  activeColor: btncolor,
                  onChanged: (Payment value) {
                    setState(() {
                      payment = value;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          );
        }
    ))
    {}
  }

  Future<void> _askedTransport() async {//運送選項對話窗
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('選擇運送方式'),
            children: <Widget>[
              ListTile(
                title: const Text('FamilyMart'),
                leading: Radio(
                  value: Transport.FamilyMart,
                  groupValue: transport,
                  activeColor: btncolor,
                  onChanged: (Transport value2) {
                    setState(() {
                      transport = value2;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('SevenEleven'),
                leading: Radio(
                  value: Transport.SevenEleven,
                  groupValue: transport,
                  activeColor: btncolor,
                  onChanged: (Transport value2) {
                    setState(() {
                      transport = value2;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('BlackCat'),
                leading: Radio(
                  value: Transport.BlackCat,
                  groupValue: transport,
                  activeColor: btncolor,
                  onChanged: (Transport value2) {
                    setState(() {
                      transport = value2;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          );
        }
    )){}
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('設定'),
        elevation:  4.0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: [
          _buildoptionbtn(Colors.lightGreen[500], '支付方式',context),//製造支付按鈕
          _buildoptionbtn(Colors.lightGreen[500], '運送方式',context),//製造運送按鈕
        ],
      ),
    );
  }
  // ignore: missing_return
  Column _buildoptionbtn(Color color, String label,BuildContext contex) {//實作製造按鈕
    if (label == '支付方式'){
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 25),
            child: FlatButton(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                _askedPayment();
              },
              color: color,
            ),
          ),
        ],
      );
    }

    if (label == '運送方式'){
      return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 25),
            child: FlatButton(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                _askedTransport();
              },
              color: color,
            ),
          ),
        ],
      );
    }
  }
}
