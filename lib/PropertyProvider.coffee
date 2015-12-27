AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides annotations for member properties that are overrides.
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

            for name, property of currentClassInfo.properties
                continue if not property.override

                regex = new RegExp("^([\\t\\ ]*)(?:public|protected|private)\\s+\\$" + name + "\\s+")

                editor.getBuffer().scan(regex, (matchInfo) =>
                    # Remove the spacing from the range.
                    matchInfo.range.start.column += matchInfo.match[1].length

                    @placeAnnotation(editor, matchInfo.range, @extractAnnotationInfo(property))

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
        # NOTE: We deliberately show the declaring class here, not the structure (which could be a trait).
        return {
            lineNumberClass : 'override'
            tooltipText     : 'Overrides property from ' + context.override.declaringClass.name
            extraData       : context.override
        }

    ###*
     * @inheritdoc
    ###
    handleMouseClick: (event, editor, annotationInfo) ->
        # 'filename' can be false for overrides of members from PHP's built-in classes (e.g. Exception).
        if annotationInfo.extraData.declaringStructure.filename
            atom.workspace.open(annotationInfo.extraData.declaringStructure.filename, {
                initialLine    : annotationInfo.extraData.declaringStructure.startLineMember - 1,
                searchAllPanes : true
            })

    ###*
     * @inheritdoc
    ###
    removePopover: () ->
        if @attachedPopover
            @attachedPopover.dispose()
            @attachedPopover = null
