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
  single_team,
  last_standing,
  all_or_nothing,
}
WinConditions winConditionFromString(String c) {
  switch (c) {
    case 'score_highest': return WinConditions.score_highest;
    case 'score_lowest': return WinConditions.score_lowest;
    case 'single_winner': return WinConditions.single_winner;
    case 'single_loser': return WinConditions.single_loser;
    case 'last_standing': return WinConditions.last_standing;
    case 'all_or_nothing': return WinConditions.all_or_nothing;
    case 'single_team': return WinConditions.single_team;
    default: return null;
  }
}
String winConditionString(WinConditions c) {
  switch (c) {
    case WinConditions.score_highest: return 'Highest Score';
    case WinConditions.score_lowest: return 'Lowest Score';
    case WinConditions.single_winner: return 'Single Winner';
    case WinConditions.single_loser: return 'Single Loser';
    case WinConditions.last_standing: return 'Last Standing';      
    case WinConditions.all_or_nothing: return 'All Win or Lose';
    case WinConditions.single_team: return 'Single Team';
    default: return '';
  }
}

enum GameType {
  standard,
  cooperative,
  team
}
GameType gameTypeFromString(String t) {
  switch (t) {
    case 'standard': return GameType.standard;
    case 'cooperative': return GameType.cooperative;
    case 'team': return GameType.team;
    default: return null;
  }
}
String gameTypeString(GameType t) {
  switch (t) {
    case GameType.standard: return 'Standard';
    case GameType.team: return 'Team';
    case GameType.cooperative: return 'Cooperative';
    default: return '';
  }
}