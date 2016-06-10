angular.module('firebase.config', [])
  .constant('FBURL', 'https://tasks-7f318.firebaseio.com')
  .constant('SIMPLE_LOGIN_PROVIDERS', ['password','google'])

  .constant('loginRedirectPath', '/login');
