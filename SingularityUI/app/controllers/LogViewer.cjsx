Controller = require './Controller'

LogLines = require '../collections/LogLines'

LogView = require '../views/logView'

Redux = require 'redux'
thunk = require 'redux-thunk'
logger = require 'redux-logger'
rootReducer = require '../reducers'
LogActions = require '../actions/log'
ActiveTasks = require '../actions/activeTasks'

class LogViewer extends Controller
  initialize: ({@requestId, @path, @initialOffset, taskIds, viewMode, search}) ->
    window.lv = @
    @title 'Tail of ' + @path

    initialState = {
        viewMode,
        colors: ['Default', 'Light', 'Dark'],
        logRequestLength: 30000,
        activeRequest: {
            @requestId
        }
    }

    @store = Redux.createStore(rootReducer, initialState, Redux.compose(Redux.applyMiddleware(thunk.default, logger())))

    if taskIds
        initPromise = @store.dispatch(LogActions.initialize(@requestId, @path, search, taskIds))
    else
        initPromise = @store.dispatch(LogActions.initializeUsingActiveTasks(@requestId, @path, search))
    
    initPromise.then =>
        @store.dispatch(ActiveTasks.updateActiveTasks(@requestId))

    # create log view
    @view = new LogView @store

    @setView @view

    @view.render()
    app.showView @view

module.exports = LogViewer