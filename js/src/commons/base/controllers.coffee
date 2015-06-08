module = angular.module("commons.base.controllers",
    ['commons.base.services', 'commons.accounts.controllers','commons.graffiti.services', 'commons.catalog.services'])



module.controller("AbstractListCtrl", ($scope, $stateParams, BareRestangular, DataSharing, FilterService) ->
    """
    Abstract controller that initialize some list filtering parameters and
    watch for changes in filterParams from FilterService
    Controllers using it need to implement a refreshList() method calling adequate [Object]Service
    """
    console.log(" Init list ctrler, defaultResultLimit = ", config.defaultResultLimit)
    $scope.params = {
            limit:config.defaultResultLimit
        }
    $scope.seeMore = false
    $scope.resultTotalCount = null
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

    $scope.refreshList = ()->
        console.log(" Abstract List Refresher (do nothing)")

    $scope.refreshListGeneric = ()->
        $scope.params['q'] = FilterService.filterParams.query
        $scope.params['facet'] = FilterService.filterParams.tags
        if config.defaultSiteTags # add tags from default "site tags" if specified
            for tag in config.defaultSiteTags
                $scope.params['facet'].push(tag)
        $scope.refreshList()

    $scope.loadAll = ()->
        """ Load all results (should be restrained regarding number of results) """
        #if  $scope.resultTotalCount < 200 (see template)
        console.log(" loading all !")
        $scope.params['limit'] = $scope.resultTotalCount
        $scope.refreshList()

    $scope.loadMore = ()->
        """ Using here custom Restangular service to use directly URL given by tastypie (nextURL) """
        BareRestangular.all($scope.nextURL).getList().then((result)->
                console.log("loading more !", result)
                for item in result
                    $scope.projectsheets.push(item)
                if result.metadata.next
                   $scope.seeMore = true
                   $scope.nextURL = result.metadata.next.slice(1) #to remove first begin slash
                else
                    $scope.seeMore = false
                $timeout(()->
                    $scope.$broadcast('projectListRefreshed')
                ,10)
            )

    $scope.init = (limit, featured) ->
        """ Init query param from stateParams (see routing in app.coffee) and template constants (limit, featured) """
        console.log(" Init List controller ! ", limit)
        if limit
             $scope.params.limit = limit
        FilterService.filterParams.query = ''
        FilterService.filterParams.tags = []
        if $stateParams.query
            DataSharing.sharedObject['stateParamQuery'] = $stateParams.query # share this with FilterCtrl
            FilterService.filterParams.query = $stateParams.query
        if $stateParams.tag
            console.log(" [List] got a tag ! ", $stateParams.tag)
            DataSharing.sharedObject['stateParamTag'] = $stateParams.tag # share this with FilterCtrl
            FilterService.filterParams.tags.push($stateParams.tag)
        $scope.refreshListGeneric()
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
