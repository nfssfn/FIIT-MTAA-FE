import 'dart:convert';

import 'package:fiit_mtaa_fe/services/http_interceptor.dart';
import 'dart:async';
import 'package:fiit_mtaa_fe/config.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:jwt_decode/jwt_decode.dart';

Map<String, dynamic> decriptedToken = {};

// ignore: mixin_inherits_from_not_object
class GameProvider with PropertyChangeNotifier<String>  {
  final httpClient = AuthenticatedHttpClient();
  Socket? socket;
  List<dynamic> usersInLobby = [];
  List<dynamic> usersForVoting = [];
  List<dynamic> killed = [];
  List<dynamic> showCamera = [];
  String gameState = 'waiting';
  String role = 'unallocated';
  bool isAdmin = false;
  bool isPrivate = false;
  String sheriffCheck = '';
  String giveWord = '';
  String winTeam = 'CIV';

  dynamic rtcInvite;
  String rtcInviteFrom = '';

  connectToRoom(id) {
    Socket socket = io('${Config.socket}/$id',
      OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build()
    );

    socket.connect();
    this.socket = socket;

    socket.onConnect((_) {
      print('lobby-register: ' + httpClient.token);
      socket.emit('lobby-register', httpClient.token);
    });
    socket.onDisconnect((_) {
      print('disconnect');
      notifyListeners('disconnect');
      gameEnd(socket);
    });

    registerListeners(socket);
  }

  leaveRoom() {
    socket?.disconnect();
  }

  startGame() {
    socket?.emit('start-game');
  }

  acceptRole() {
    socket?.emit('role-accepted');
  }

  vote(username) {
    socket?.emit('game-vote', username);
  }

  sendRtc(String username, String from, session) {
    // socket?.emit('rtc-transmit', { 'to': [username], 'from': from, 'invite': session });
    socket?.emit('rtc-transmit-inv', { 'to': [username], 'from': from, 'invite': session });
  }

  kickUser(username) {
    print('kick-user: ' + username);
    socket?.emit('kick-user', username);
  }

  registerListeners(Socket socket) {
    socket.on('lobby-info', (data) {
      isAdmin = data['isAdmin'];
      isPrivate = data['isPrivate'];
    });
    socket.on('lobby-list', (data) {
      usersInLobby = data;
      notifyListeners();
    });
    socket.on('lobby-register-error', (data) {
      print('lobby-register-error: ' + data.toString());
      notifyListeners();
    });
    socket.on('game-preparing', (data) {
      print('game-preparing');
      gameState = 'preparing';
      notifyListeners();
    });
    socket.on('role-set', (data) {
      print('role-set: ' + data);
      gameState = 'role-set';
      role = data;
      notifyListeners('role-set');
    });
    socket.on('game-fail', (data) {
      print('game-fail');
      leaveRoom();
    });
    socket.on('game-started', (data) {
      print('game-started');
      gameState = 'game-started';
      notifyListeners('game-started');
    });
    socket.on('game-night', (data) {
      print('game-night');
      gameState = 'night';
      notifyListeners('game-night');
    });
    socket.on('game-day', (data) {
      print('game-day');
      gameState = 'day';
      notifyListeners();
    });
    socket.on('game-rtc-hide-all', (data) {
      print('game-rtc-hide-all');
      gameState = 'game-rtc-hide-all';
      showCamera = [];
      giveWord = '';
      notifyListeners();
    });
    socket.on('game-rtc-show', (data) {
      print('game-rtc-show: ' + data.toString());
      gameState = 'game-rtc-show: ' + data.toString();
      showCamera = data;
      // String username = Jwt.parseJwt(httpClient.token)['username'];
      // if (data.indexOf(username) >= 0) {
      //   showCamera = true;
      // }
      notifyListeners();
    });
    socket.on('game-voting', (data) {
      print('game-voting: ' + data.toString());
      gameState = 'game-voting: ' + data.toString();
      usersForVoting = data;
      notifyListeners('game-voting');
    });
    socket.on('game-voting-end', (data) {
      print('game-voting-end');
      gameState = 'game-voting-end';
      usersForVoting = [];
      notifyListeners();
    });
    socket.on('game-give-word', (data) {
      print('game-give-word: ' + data);
      gameState = 'game-give-word: ' + data;
      giveWord = data;
      notifyListeners('give-word');
    });
    socket.on('game-killed', (data) {
      print('game-killed: ' + data);
      String username = Jwt.parseJwt(httpClient.token)['username'];
      if (data == username)
        role = 'killed';
      killed.add(data);
      notifyListeners();
    });
    socket.on('game-sheriff-check', (data) {
      print('game-sheriff-check: ' + data.toString());
      gameState = 'game-sheriff-check: ' + data.toString();
      sheriffCheck = data.toString();
      notifyListeners('game-sheriff-check');
    });
    socket.on('game-over', (data) {
      print('game-over: ' + data);
      gameState = 'game-over: ' + data;
      winTeam = data;
      notifyListeners('game-over');
      leaveRoom();
    });
    // socket.on('rtc-recieve', (data) {
    socket.on('rtc-rcv', (data) {
      print('rtc-rcv: ');
      rtcInvite = data['invite'];
      rtcInviteFrom = data['from'];
      print(rtcInvite);
      notifyListeners('rtc-rcv');
    });
  }

  gameEnd(Socket socket) {
    gameState = 'waiting';
    role = 'unallocated';
    usersInLobby = [];
    usersForVoting = [];
    isAdmin = false;
    isPrivate = false;
    killed = [];
    // showCamera = false;
    showCamera = [];

    this.socket = null;
  }

  Future<Map<String, dynamic>> getGames() async {
    final response = await httpClient.get(Uri.parse(Config.games));

    if (response.statusCode == 200) {
      return { 'status': true, 'games': jsonDecode(response.body) };
    } else {
      return { 'status': false, 'message': response.body };
    }
  }

  Future<Map<String, dynamic>> createGame(bool isPrivate) async {
    final response = await httpClient.post(
      Uri.parse(Config.games),
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode({ 'private': isPrivate, 'maxPlayers': Config.maxPlayers })
    );

    if (response.statusCode == 201) {
      return { 'status': true, 'id': jsonDecode(response.body)['id'] };
    } else {
      return { 'status': false, 'message': response.body };
    }
  }

  Future<Map<String, dynamic>> deleteGame(String id) async {
    final response = await httpClient.delete(
      Uri.parse(Config.games),
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode({ 'id': id })
    );

    if (response.statusCode == 200) {
      return { 'status': true };
    } else {
      return { 'status': false, 'message': response.body };
    }
  }

}