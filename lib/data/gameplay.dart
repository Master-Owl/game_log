import './game.dart';
import './player.dart';

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
  GamePlay(this.game, this.players, { this.playDate, this.playTime, this.scores, this.teams, this.winners }) {
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
}