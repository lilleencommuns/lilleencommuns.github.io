module = angular.module('commons.base.filters', [])

module.filter('tagFieldNotInArray', ->
    """
    Filter out items whose field "fieldName" is contained within a given "array"
    """
    return (items, array, fieldName)-> 
        filtered = _.reject(
            items,
            (item)->
                return _.contains(array, item[fieldName])
        )
        return filtered
)