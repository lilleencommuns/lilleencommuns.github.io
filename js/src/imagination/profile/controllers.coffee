module = angular.module("imagination.profile.controllers", ['imagination.profile.services',
        'commons.base.services', 'commons.catalog.services', 'commons.accounts.services', 'commons.base.controllers', 'imagination.catalog.controllers'])

module.controller("ImaginationProfileListCtrl", ($scope, $controller, Profile) ->
    angular.extend(this, $controller('AbstractListCtrl', {$scope: $scope}))

    $scope.refreshList = ()->
        # FIXME : implement filter
        $scope.profiles = Profile.one().getList().$object
)

module.controller("ImaginationProfileCtrl", ($scope, $stateParams, Profile, Project, ObjectProfileLink, PostalAddress, TaggedItem) ->

    Profile.one($stateParams.id).get().then((profileResult) ->
        $scope.profile = profileResult

        $scope.preparedInterestTags = []
        $scope.preparedSkillTags = []

        $scope.member_projects = []
        $scope.member_resources = []
        $scope.fan_projects = []
        $scope.fan_resources = []

        ObjectProfileLink.getList({content_type:'project', profile__id : $scope.profile.id}).then((linkedProjectResults)->
            angular.forEach(linkedProjectResults, (linkedProject) ->
                Project.one().get({id : linkedProject.object_id}).then((projectResults) ->
                    if projectResults.objects.length == 1
                        if linkedProject.level == 0
                            $scope.member_projects.push(projectResults.objects[0])
                            angular.forEach(projectResults.objects[0].tags, (projectTag)->
                                console.log("interest tags : ", projectTag)
                                $scope.preparedInterestTags.push({text : projectTag.tag.name, taggedItemId : projectTag.id})
                                )
                        else if linkedProject.level == 2
                            $scope.fan_projects.push(projectResults.objects[0])
                )
            )
        )


        angular.forEach($scope.profile.tags, (taggedItem) ->
            $scope.preparedInterestTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
            # switch taggedItem.tag_type
            #     when "in" then $scope.preparedInterestTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
            #     when "sk" then $scope.preparedSkillTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
        )

        $scope.addTagToProfile = (tag_type, tag) ->
            TaggedItem.one().customPOST({tag : tag.text}, "profile/"+$scope.profile.id, {})

        $scope.removeTagFromProfile = (tag) ->
            TaggedItem.one(tag.taggedItemId).remove()

        $scope.updateProfile = (resourceName, resourceId, fieldName, data) ->
            # in case of MakerScienceProfile, resourceId must be the profile slug
            putData = {}
            putData[fieldName] = data
            switch resourceName
                when 'Profile' then Profile.one(resourceId).patch(putData)
                when 'PostalAddress' then PostalAddress.one(resourceId).patch(putData)

        $scope.updateSocialNetworks = (profileSlug, socials) ->
            """
            FIXME : add socials fields to generic Profiles object
            """
            Profile.one(profileSlug).patch(socials)
    )
)
