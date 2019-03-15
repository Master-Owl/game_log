import './game.dart';
import './player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// GamePlays always have an associated game
/// and a list of players. It should also
/// generally have a play date & play time (duration).
/// 
/// Depending on the game type it may or 
/// may not have other fields:
/// 
/// Standard:
///  [x] scores
///  [x] winners
///  [] teams
/// 
/// Cooperative:
///  [] scores
///  [x] winners
///  [] teams
/// 
/// Team:
///  [] scores
///  [x] winners
///  [x] teams

class GamePlay {
  GamePlay(this.game, this.players, { this.playDate, this.playTime, this.scores, this.teams, this.winners, this.dbRef }) {
    if (game == null) game = new Game(name: '');
    if (players == null) {
      players = [];
      winners = [];
      teams = {};
      scores = {};
    }
    if (playDate == null) {
      playDate = DateTime.now();
    }
    if (playTime == null) {
      playTime = Duration(minutes: 0);
    }
  }

  Game game;
  DateTime playDate;
  Duration playTime;

  List<Player> players;
  List<Player> winners;
  Map<Player, int> scores;
  Map<String, List<Player>> teams;

  DocumentReference dbRef;

  Map<String, dynamic> serialize() {
    Map<String, dynamic> data = {};
    
    data['game'] = game.dbRef;
    data['playdate'] = playDate;
    data['playtime'] = playTime.inMinutes;
    

    if (players.length > 0) {      
      List<DocumentReference> pRefs = [];
      for (Player p in players) {
        pRefs.add(p.dbRef);
      }
      data['players'] = pRefs;
    }

    if (scores.length > 0) {
      Map<String, int> pScores = {};
      for (Player p in scores.keys) {
        pScores[p.dbRef.documentID] = scores[p];
      }
      data['scores'] = pScores;
    }

    if (winners.length > 0) {
      List<DocumentReference> winnerRefs = [];
      for (Player p in winners) {
        winnerRefs.add(p.dbRef);
      }
      data['winners'] = winnerRefs;
    }

    if (teams.length > 0) {
      Map<String, List<DocumentReference>> teamRefs = {};
      for (String teamName in teams.keys) {
        List<DocumentReference> pRefs = [];
        for (Player p in teams[teamName]) {
          pRefs.add(p.dbRef);
        }
        teamRefs[teamName] = pRefs;
      }
      data['teams'] = teamRefs;
    }

    return data;
  }
}