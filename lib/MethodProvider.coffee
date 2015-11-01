AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides annotations for member methods that are overrides or interface implementations.
##
class MethodProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    regex: /(\s*(?:public|protected|private)\s+function\s+)(\w+)\s*\(/g

    ###*
     * @inheritdoc
    ###
    extractAnnotationInfo: (editor, row, rowText, match) ->
        currentClass = @service.determineFullClassName(editor)

        methodName = match[2]

        context = @service.getClassMethod(currentClass, methodName)

        if not context or (not context.override and not context.implementation)
            return null

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
