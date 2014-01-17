View = require './view'

numberAttributes = [
    'activeTasks'
    'requests'
    'pausedRequests'
    'scheduledTasks'
    'pendingRequests'
    'cleaningRequests'
    'activeSlaves'
    'deadSlaves'
    'decomissioningSlaves'
    'activeRacks'
    'deadRacks'
    'decomissioningRacks'
    'numWebhooks'
    'cleaningTasks'
    'lateTasks'
    'futureTasks'
]

class DashboardView extends View

    template: require './templates/dashboard'

    initialize: ->
        @captureLastStateAttributes()

    captureLastStateAttributes: ->
        @lastStateAttributes = $.extend {}, app.state.attributes

    fetch: ->
        @captureLastStateAttributes()
        app.state.fetch()

    refresh: ->
        @fetch(@lastTasksFilter).done =>
            @render(@lastTasksFilter)

    render: =>
        changedNumbers = {}

        for numberAttribute in numberAttributes
            oldNumber = @lastStateAttributes[numberAttribute]
            newNumber = app.state.attributes[numberAttribute]
            if oldNumber isnt newNumber
                changedNumbers[numberAttribute] =
                    direction: "#{ if newNumber > oldNumber then 'inc' else 'dec' }rease"
                    difference: "#{ if newNumber > oldNumber then '+' else '-' }#{ Math.abs(newNumber - oldNumber) }"

        @$el.html @template state: @lastStateAttributes

        for attributeName, changes of changedNumbers
            $number = @$el.find(""".number[data-state-attribute="#{ attributeName }"]""")
            $bigNumber = $number.parents('.big-number-link')
            changeClassName = "changed-direction-#{ changes.direction }"
            $bigNumber.addClass changeClassName
            $bigNumber.find('.well').attr('data-changed-difference', changes.difference)
            $number.html app.state.attributes[attributeName]
            do ($bigNumber, changeClassName) -> setTimeout (-> $bigNumber.removeClass changeClassName), 2000

        utils.setupSortableTables()

module.exports = DashboardView