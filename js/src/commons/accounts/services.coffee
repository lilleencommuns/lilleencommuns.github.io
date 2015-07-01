module = angular.module("commons.accounts.services", ['restangular'])


module.factory('User', (Restangular) ->
    return Restangular.service('account/user')
)

module.factory('Profile', (Restangular) ->
    return Restangular.service('account/profile')
)

module.factory('ObjectProfileLink', (Restangular) ->
    return Restangular.service('objectprofilelink')
)

class CurrentProfileService
    constructor : ($rootScope, $modal, Profile) ->
        console.log( " Init CurrentProfileService ")
        if $rootScope.authVars.isAuthenticated
            $rootScope.currentProfile = Profile.one().get('user__username':$rootScope.authVars.username).then((profileResult)->
                $rootScope.currentProfile = profileResult.objects[0]
            )

        $rootScope.openSignupPopup = ()->
            modalInstance = $modal.open(
                templateUrl: 'views/base/signupModal.html',
                controller: 'SignupPopupCtrl'
            )

        $rootScope.openSigninPopup = ()->
            $rootScope.authVars.loginrequired = true
            modalInstance = $modal.open(
                templateUrl: 'views/base/signinModal.html',
                controller: 'SigninPopupCtrl'
            )

        $rootScope.$watch('authVars.username', (newValue, oldValue) ->
            if (newValue != oldValue) && (newValue != '')
                Profile.one().get({'user__username':newValue}).then((profileResult)->
                        $rootScope.currentProfile = profileResult.objects[0]
                        console.log(" CurrentProfile result ", profileResult)
                        console.log(" CurrentProfile updated ! ", $rootScope.currentProfile )
                )
        )


module.factory('CurrentProfileService', ($rootScope, $modal, Profile) ->
    return new CurrentProfileService($rootScope, $modal, Profile)
)


module.controller('SignupPopupCtrl', ($scope, $rootScope, $modalInstance, $state, User) ->
    """
    Controller bound to openSignupPopup method of CurrentProfile service
    """
    $scope.register = ->
        $scope.user.email = $scope.user.username
        User.post($scope.user).then((userResult) ->
            $rootScope.authVars.username = $scope.user.username
            $rootScope.authVars.password = $scope.user.password
            $rootScope.loginService.submit()
            $modalInstance.close()
        )
)

module.controller('SigninPopupCtrl', ($scope, $rootScope, $modalInstance, $state, User) ->
    """
    Controller bound to openSigninPopup method of CurrentProfile service
    """
    console.log(" init signin ctrler")
    #
    $rootScope.$watch('authVars.isAuthenticated', (newValue, oldValue) ->
        console.log(" isAuthenticated ? ", newValue)
        if newValue == true
            $modalInstance.close()
    )
)
