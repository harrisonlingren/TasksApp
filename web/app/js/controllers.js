angular.module('TasksApp.controllers', []).controller('tasksController', function($scope, firebaseAPI) {
	$scope.taskList = []; // Set to data from Firebase here
	
	firebaseAPI.getTasks().success(function (response) {
		alert(response);
		// Get data from response
		$scope.taskList = response
	}
});