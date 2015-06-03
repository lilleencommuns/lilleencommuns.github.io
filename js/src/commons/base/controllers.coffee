module = angular.module("commons.base.controllers",
    ['commons.base.services', 'commons.accounts.controllers','commons.graffiti.services'])



module.controller("AbstractListCtrl", ($scope, FilterService) ->
    """
    Abstract controller that initialize some list filtering parameters and
    watch for changes in filterParams from FilterService
    Controllers using it need to implement a refreshList() method calling adequate [Object]Service
    """
    $scope.params = {
            limit:12
        }
    $scope.refreshList = ()->
        console.log(" Abstract List Refresher (do nothing)")

    $scope.refreshListGeneric = ()->
        $scope.params['q'] = FilterService.filterParams.query
        $scope.params['facet'] = FilterService.filterParams.tags
        if config.defaultSiteTags # add tags from default "site tags" if specified
            for tag in config.defaultSiteTags 
                FilterService.filterParams.tags.push(tag)
        $scope.refreshList()

    $scope.init = (limit, featured) ->
        if limit
             $scope.params.limit = limit
        # Refresh FilterService params
        FilterService.filterParams.query = ''
        FilterService.filterParams.tags = []
        $scope.refreshListGeneric()
    
        $scope.$watch(
            ()->
                return FilterService.filterParams.tags
            ,(newVal, oldVal) ->
                if newVal != oldVal
                    $scope.refreshListGeneric()
        )
        $scope.$watch(
            ()->
                return FilterService.filterParams.query
            ,(newVal, oldVal) ->
                if newVal != oldVal
                    $scope.refreshListGeneric()
        )
)


module.controller("ObjectGetter", ($scope, Project, Profile) ->

    $scope.getObject = (objectTypeName, objectId) ->
        if objectTypeName == 'project'
            Project.one(objectId).get().then((ProjectResult) ->
                $scope.project = ProjectResult
            )
        if objectTypeName == 'profile'
            Profile.one(objectId).get().then((ProfileResult) ->
                $scope.profile = ProfileResult
            )
)

