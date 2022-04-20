class Config {
  static const String apiUrl = 'http://20.224.137.80:3000';
  static const String socket = 'http://20.224.137.80:3030';

  static const String login = apiUrl + '/account/login';
  static const String register = apiUrl + '/account/register';

  static const String changePassword = apiUrl + '/account/change-password';
  static const String avatar = apiUrl + '/account/avatar';
  static const String deleteAccount = apiUrl + '/account/delete-account';

  static const String games = apiUrl + '/game/rooms';


  static const int maxPlayers = 4;

  static const roles = {
    'CIV': 'Civilian',
    'MAF': 'Mafia',
    'DOC': 'Doctor',
    'SRF': 'Commisar',

    'killed': 'Killed',

    'fallback': 'no role'
  };

  static const rolesDescription = {
    'CIV': 'You are Civilian. Civilians are attempting to figure out who is in the mafia simply by talking it out, accusing, and seeing who is acting suspicious. As a civilian, it’s best to use verbal/non-verbal cues and your gut to make alliances.',
    'MAF': 'You are Mafia. Mafia find out each other’s identity in the first nighttime phase. While the other players are attempting to figure out who they are, the mafia must lie throughout the entire game and act as though they are civilians. The mafia must strategize together during the day without giving themselves away. At night, when the mafia awaken, they point silently to the player they’d like to kill. If all mafia agree, the player is offed.',
    'DOC': 'You are Doctor. Doctor is a civilian role that, at each nighttime phase, can save a player he or she thinks the mafia has killed. As mentioned earlier, if the doctor saves the right player, that player is brought back into the game.',
    'SRF': 'You are Commisar. Commisar is a civilian role that, at each nighttime phase, can point to a player he or she thinks is in the mafia and check is it true or not.',

    'killed': 'You are killed.',

    'fallback': 'This is fallback text. Role is not setted.'
  };
}
