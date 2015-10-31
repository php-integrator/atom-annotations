{TextEditor, Point, Range} = require 'atom'

$ = require 'jquery'
SubAtom = require 'sub-atom'

module.exports =

##*
# Base class for providers.
##
class AbstractProvider
    ###*
     * The regular expression that a line must match in order for it to be checked if it requires an annotation.
    ###
    regex: null

    ###*
     * List of markers that are present for each file.
    ###
    markers: null

    ###*
     * SubAtom objects for each file.
    ###
    subAtoms: null

    ###*
     * The service (that can be used to query the source code and contains utility methods).
    ###
    service: null

    constructor: () ->
        # Constructer here because otherwise the object is shared between instances.
        @markers  = {}
        @subAtoms = []

    ###*
     * Initializes this provider.
     *
     * @param {mixed} service
    ###
    activate: (@service) ->
        atom.workspace.observeTextEditors (editor) =>
            @registerAnnotations(editor)
            @registerEvents(editor)

        # When you go back to only have one pane the events are lost, so need to re-register.
        atom.workspace.onDidDestroyPane (pane) =>
            panes = atom.workspace.getPanes()

            if panes.length == 1
                @registerEventsForPane(panes[0])

        # Having to re-register events as when a new pane is created the old panes lose the events.
        atom.workspace.onDidAddPane (observedPane) =>
            panes = atom.workspace.getPanes()

            for pane in panes
                if pane != observedPane
                    @registerEventsForPane(pane)

    ###*
     * Registers the necessary event handlers for the editors in the specified pane.
     *
     * @param {Pane} pane
    ###
    registerEventsForPane: (pane) ->
        for paneItem in pane.items
            if paneItem instanceof TextEditor
                @registerEvents(paneItem)

    ###*
     * Deactives the provider.
    ###
    deactivate: () ->
        @removeAnnotations()

    ###*
     * Registers the necessary event handlers.
     *
     * @param {TextEditor} editor TextEditor to register events to.
    ###
    registerEvents: (editor) ->
        if editor.getGrammar().scopeName.match /text.html.php$/
            # Ticket #107 - Mouseout isn't generated until the mouse moves, even when scrolling (with the keyboard or
            # mouse). If the element goes out of the view in the meantime, its HTML element disappears, never removing
            # it.
            editor.onDidDestroy () =>
                @removePopover()

            editor.onDidStopChanging () =>
                @removePopover()

            editor.onDidSave (event) =>
                @rescan(editor)

            textEditorElement = atom.views.getView(editor)

            $(textEditorElement.shadowRoot).find('.horizontal-scrollbar').on 'scroll', () =>
                @removePopover()

            $(textEditorElement.shadowRoot).find('.vertical-scrollbar').on 'scroll', () =>
                @removePopover()

    ###*
     * Registers the annotations.
     *
     * @param {TextEditor} editor The editor to search through.
    ###
    registerAnnotations: (editor) ->
        @subAtoms[editor.getLongTitle()] = new SubAtom

        for i in [0 .. editor.getLineCount() - 1]
            row = editor.lineTextForBufferRow(i)

            continue if not row

            while (match = @regex.exec(row))
                @placeAnnotation(editor, i, row, match)

    ###*
     * Places an annotation at the specified line and row text.
     *
     * @param {TextEditor} editor
     * @param {number}     row
     * @param {string}     rowText
     * @param {array}      match
    ###
    placeAnnotation: (editor, row, rowText, match) ->
        annotationInfo = @extractAnnotationInfo(editor, row, rowText, match)

        if not annotationInfo
            return

        range = new Range(
            new Point(parseInt(row), 0),
            new Point(parseInt(row), rowText.length)
        )

        # NOTE: New markers are added on startup as initialization is done, so making them persistent will cause the
        # 'storage' file of the project (in Atom's config folder) to grow forever (in a way it's a memory leak).
        marker = editor.markBufferRange(range, {
            maintainHistory : true
            persistent      : false
            invalidate      : 'touch'
        })

        decoration = editor.decorateMarker(marker, {
            type: 'line-number',
            class: annotationInfo.lineNumberClass
        })

        longTitle = editor.getLongTitle()

        if longTitle not of @markers
            @markers[longTitle] = []

        @markers[longTitle].push(marker)

        @registerAnnotationEventHandlers(editor, row, annotationInfo)

    ###*
     * Exracts information about the annotation match.
     *
     * @param {TextEditor} editor
     * @param {int}        row
     * @param {String}     rowText
     * @param {Array}      match
    ###
    extractAnnotationInfo: (editor, row, rowText, match) ->

    ###*
     * Registers annotation event handlers for the specified row.
     *
     * @param {TextEditor} editor
     * @param {int}        row
     * @param {Object}     annotationInfo
    ###
    registerAnnotationEventHandlers: (editor, row, annotationInfo) ->
        textEditorElement = atom.views.getView(editor)
        gutterContainerElement = $(textEditorElement.shadowRoot).find('.gutter-container')

        do (editor, gutterContainerElement, annotationInfo) =>
            longTitle = editor.getLongTitle()
            selector = '.line-number' + '.' + annotationInfo.lineNumberClass + '[data-buffer-row=' + row + '] .icon-right'

            @subAtoms[longTitle].add gutterContainerElement, 'mouseover', selector, (event) =>
                @handleMouseOver(event, editor, annotationInfo)

            @subAtoms[longTitle].add gutterContainerElement, 'mouseout', selector, (event) =>
                @handleMouseOut(event, editor, annotationInfo)

            @subAtoms[longTitle].add gutterContainerElement, 'click', selector, (event) =>
                @handleMouseClick(event, editor, annotationInfo)

    ###*
     * Handles the mouse over event on an annotation.
     *
     * @param {jQuery.Event} event
     * @param {TextEditor}   editor
     * @param {Object}       annotationInfo
    ###
    handleMouseOver: (event, editor, annotationInfo) ->
        if annotationInfo.tooltipText
            @removePopover()

            @attachedPopover = @service.createAttachedPopover(event.target)
            @attachedPopover.setText(annotationInfo.tooltipText)
            @attachedPopover.show()

    ###*
     * Handles the mouse out event on an annotation.
     *
     * @param {jQuery.Event} event
     * @param {TextEditor}   editor
     * @param {Object}       annotationInfo
    ###
    handleMouseOut: (event, editor, annotationInfo) ->
        @removePopover()

    ###*
     * Handles the mouse click event on an annotation.
     *
     * @param {jQuery.Event} event
     * @param {TextEditor}   editor
     * @param {Object}       annotationInfo
    ###
    handleMouseClick: (event, editor, annotationInfo) ->

    ###*
     * Removes the existing popover, if any.
    ###
    removePopover: () ->
        if @attachedPopover
            @attachedPopover.dispose()
            @attachedPopover = null

    ###*
     * Removes any annotations that were created for the specified editor.
     *
     * @param {TextEditor} editor
    ###
    removeAnnotationsFor: (editor) ->
        @removeAnnotationsByKey(editor.getLongTitle())

    ###*
     * Removes any annotations that were created with the specified key.
     *
     * @param {string} key
    ###
    removeAnnotationsByKey: (key) ->
        for i,marker of @markers[key]
            marker.destroy()

        @markers[key] = []
        @subAtoms[key]?.dispose()

    ###*
     * Removes any annotations (across all editors).
    ###
    removeAnnotations: () ->
        for key,markers of @markers
            @removeAnnotationsByKey(key)

        @markers = {}

    ###*
     * Rescans the editor, updating all annotations.
     *
     * @param {TextEditor} editor The editor to search through.
    ###
    rescan: (editor) ->
        @removeAnnotationsFor(editor)
        @registerAnnotations(editor)
