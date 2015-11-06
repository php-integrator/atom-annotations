AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides annotations for member methods that are overrides or interface implementations.
##
class MethodProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    registerAnnotations: (editor) ->
        currentClass = @service.determineFullClassName(editor)

        return if not currentClass

        successHandler = (currentClassInfo) =>
            return if not currentClassInfo

            for name, method of currentClassInfo.methods
                continue if not method.override and not method.implementation

                regex = new RegExp("^([\\t\\ ]*)((?:public|protected|private)\\s+function\\s+" + name + "\\s*)\\(")

                editor.getBuffer().scan(regex, (matchInfo) =>
                    # Remove the spacing from the range.
                    matchInfo.range.start.column += matchInfo.match[1].length

                    @placeAnnotation(editor, matchInfo.range, @extractAnnotationInfo(method))

                    matchInfo.stop()
                )

        failureHandler = () =>
            # Just do nothing.

        @service.getClassInfo(currentClass, true).then(successHandler, failureHandler)

    ###*
     * Fetches annotation info for the specified context.
     *
     * @param {Object} context
     *
     * @return {Object}
    ###
    extractAnnotationInfo: (context) ->
        extraData = null
        tooltipText = ''
        lineNumberClass = ''

        # NOTE: We deliberately show the declaring class here, not the structure (which could be a trait).
        if context.override
            extraData = context.override
            lineNumberClass = 'override'
            tooltipText = 'Overrides method from ' + extraData.declaringClass.name

        else
            extraData = context.implementation
            lineNumberClass = 'implementation'
            tooltipText = 'Implements method for ' + extraData.declaringClass.name

        return {
            lineNumberClass : lineNumberClass
            tooltipText     : tooltipText
            extraData       : extraData
        }

    ###*
     * @inheritdoc
    ###
    handleMouseClick: (event, editor, annotationInfo) ->
        # 'filename' can be false for overrides of members from PHP's built-in classes (e.g. Exception).
        if annotationInfo.extraData.declaringStructure.filename
            atom.workspace.open(annotationInfo.extraData.declaringStructure.filename, {
                initialLine    : annotationInfo.extraData.startLine - 1,
                searchAllPanes : true
            })

    ###*
     * @inheritdoc
    ###
    removePopover: () ->
        if @attachedPopover
            @attachedPopover.dispose()
            @attachedPopover = null
