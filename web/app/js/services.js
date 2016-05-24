angular.module('TasksApp.services', []).factory('firebaseAPI', function($http) {
		var q = {};
		q.getTasks = function() {
		  return $http({
			method: 'JSONP', 
			url: 'https://tasks-7f318.firebaseio.com/tasks.json'
		  });
		}
		return q;
  });