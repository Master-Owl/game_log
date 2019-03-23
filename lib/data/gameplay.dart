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
  GamePlay(this.game, this.playerRefs, { this.playDate, this.playTime, this.scores, this.teams, this.winners, this.dbRef, this.players }) {
    if (game == null) game = new Game(name: '');
    if (playerRefs == null) {
      playerRefs = [];
    }
    if (players == null) {
      players = [];
    }
    if (teams == null) {
      teams = {};
    }
    if (winners == null) {
      winners = [];
    }
    if (scores == null) {
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
  List<DocumentReference> playerRefs;
  List<String> winners;
  Map<String, int> scores;
  Map<String, List<DocumentReference>> teams;

  DocumentReference dbRef;

  int get playerCount => playerRefs.length;

  Map<String, dynamic> serialize() {
    Map<String, dynamic> data = {};
    data['game'] = game.dbRef;
    data['playdate'] = playDate;
    data['playtime'] = playTime.inMinutes;
    data['winners'] = winners;
    // data['teams'] = teams;

    if (playerRefs == null || (playerRefs.length == 0 && players.length > 0)) {
      for (Player p in players) {
        playerRefs.add(p.dbRef);
      }
    }

    data['players'] = playerRefs;
    
    if (scores.length > 0) {
      Map<String, int> pScores = {};
      for (String pRef in scores.keys) {
        pScores[pRef] = scores[pRef];
      }
      data['scores'] = pScores;
    }

    if (teams.keys.length > 0) {
      Map<String, List<DocumentReference>> teamRefs = {};
      for (String teamName in teams.keys) {
        List<DocumentReference> pRefs = [];
        for (DocumentReference p in teams[teamName]) {
          pRefs.add(p);
        }
        teamRefs[teamName] = pRefs;
      }
      data['teams'] = teamRefs;
    }

    return data;
  }
}