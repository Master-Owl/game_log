import './game.dart';
import './player.dart';

class GamePlay {
  GamePlay({ this.game, this.players, this.winners, this.scores }) {
    if (game == null) game = new Game(name: '');
    if (players == null) {
      players = [];
      winners = {};
      scores = {};
    }
  }

  Game game;
  List<Player> players;

  // int refers to the list index of the player
  Map<int, bool> winners;
  Map<int, int> scores;
}