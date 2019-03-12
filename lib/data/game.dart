enum WinConditions {
  score_highest,
  score_lowest,
  last_standing
}

class Game {
  Game({ this.name, this.condition, this.teamGame, this.bggId }) {
    if (name == null) name = '';
    if (condition == null) condition =WinConditions.score_highest;
    if (teamGame == null) teamGame = false;
    if (bggId == null) bggId = -1;
  }

  String name;
  WinConditions condition;
  bool teamGame;
  int bggId;
}