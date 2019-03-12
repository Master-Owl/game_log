class Game {
  Game({ this.name, this.condition, this.type, this.bggId, this.dbId }) {
    if (name == null) name = '';
    if (condition == null) condition = WinConditions.score_highest;
    if (type == null) type = GameType.standard;
    if (bggId == null) bggId = -1;
  }

  String winConditionEnumString() =>
    '${condition.toString().substring(condition.toString().indexOf('.')+1)}';
  String gameTypeEnumString() =>
    '${type.toString().substring(type.toString().indexOf('.')+1)}';

  String name;
  WinConditions condition;
  GameType type;
  int bggId;
  String dbId;
}

enum WinConditions {
  score_highest,
  score_lowest,
  single_winner,
  single_loser,
  last_standing
}

String winConditionString(WinConditions c) {
  switch (c) {
    case WinConditions.score_highest: return 'Highest Score';
    case WinConditions.score_lowest: return 'Lowest Score';
    case WinConditions.single_winner: return 'Single Winner';
    case WinConditions.single_loser: return 'Single Loser';
    case WinConditions.last_standing: return 'Last Standing';      
    default: return '';
  }
}

enum GameType {
  standard,
  cooperative,
  team
}

String gameTypeString(GameType t) {
  switch (t) {
    case GameType.standard: return 'Standard';
    case GameType.team: return 'Team';
    case GameType.cooperative: return 'Cooperative';
    default: return '';
  }
}