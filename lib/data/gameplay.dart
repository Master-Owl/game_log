import './game.dart';
import './player.dart';

class GamePlay {
  GamePlay({ this.game, this.players, this.winners, this.scores, this.playDate, this.playTime }) {
    if (game == null) game = new Game(name: '');
    if (players == null) {
      players = [];
      winners = {};
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
  List<Player> players;
  DateTime playDate;
  Duration playTime;

  // int refers to the list index of the player
  Map<int, bool> winners;
  Map<int, int> scores;
}