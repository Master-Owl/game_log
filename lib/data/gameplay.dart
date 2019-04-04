import 'dart:async';
import 'package:game_log/data/game.dart';
import 'package:game_log/data/player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_log/data/globals.dart';

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
///  [/] scores
///  [x] winners
///  [] teams
/// 
/// Team:
///  [/] scores
///  [x] winners
///  [x] teams

class GamePlay {
  GamePlay(this.game, this.playerRefs, { this.playDate, this.playTime, this.scores, this.teams, this.winners, this.dbRef, this.wonGame }) {
    if (game == null) game = new Game(name: '');
    if (playerRefs == null) {
      playerRefs = [];
    }
    if (teams == null) {
      teams = {};
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
    if (wonGame == null) {
      wonGame = false;
    }
    if (winners == null) {
      _determineWinners();
    }
  }

  static GamePlay clone(GamePlay play) {
    GamePlay clone = GamePlay(play.game, []);
    clone.playerRefs = List.from(play.playerRefs);
    clone.teams = Map.from(play.teams);
    clone.scores = Map.from(play.scores);
    clone.winners = List.from(play.winners);
    clone.playDate = play.playDate;
    clone.playTime = play.playTime;
    clone.wonGame = play.wonGame;
    clone.dbRef = play.dbRef;
    return clone;
  }

  void _determineWinners() {
    dynamic winningScore;
    switch (game.condition) {
      case WinConditions.score_highest:
        winners = [];
        winningScore = -double.infinity;
        for (String player in scores.keys) {
          int score = scores[player];
          if (score > winningScore) {
            winningScore = score;
            winners.clear();
            winners.add(player);
          }
          else if (score == winningScore) {
            winners.add(player);
          }
        }
        break;
      case WinConditions.score_lowest:
        winners = [];
        winningScore = double.infinity;
        for (String player in scores.keys) {
          int score = scores[player];
          if (score < winningScore) {
            winningScore = score;
            winners.clear();
            winners.add(player);
          }
          else if (score == winningScore) {
            winners.add(player);
          }
        }
        break;
      case WinConditions.all_or_nothing:
        winners = [];
        winners.clear();
        if (wonGame) {
          for (DocumentReference pRef in playerRefs) {
            winners.add(pRef.documentID);
          }
        }
        break;
      default: break;
    }
  }

  Game game;
  DateTime playDate;
  Duration playTime;
  bool wonGame;

  List<DocumentReference> playerRefs;
  List<String> winners;
  Map<String, int> scores;
  Map<String, List<DocumentReference>> teams;

  DocumentReference dbRef;

  Future<List<Player>> getPlayers() => getPlayersFromRefs(playerRefs);
  int get playerCount => playerRefs.length;

  Map<String, dynamic> serialize() {
    Map<String, dynamic> data = {};
    data['game'] = game.dbRef;
    data['players'] = playerRefs;
    data['playdate'] = playDate;
    data['playtime'] = playTime.inMinutes;
    

    _determineWinners();
    data['winners'] = winners;
    
    if (scores.length > 0) {
      Map<dynamic, dynamic> pScores = {};
      for (String pRef in scores.keys) {
        pScores[pRef] = scores[pRef];
      }
      data['scores'] = pScores;
    }

    if (teams.keys.length > 0) {
      Map<dynamic, dynamic> teamRefs = {};
      for (String teamName in teams.keys) {
        List<DocumentReference> pRefs = [];
        for (DocumentReference p in teams[teamName]) {
          pRefs.add(p);
        }
        teamRefs[teamName] = pRefs;
      }
      data['teams'] = teamRefs;
    }

    if (game.condition == WinConditions.all_or_nothing) {
      data['won'] = wonGame;
    }

    return data;
  }
}