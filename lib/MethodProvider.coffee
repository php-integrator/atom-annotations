{Range} = require 'atom'

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
        path = editor.getPath()

        return if not path

        successHandler = (classInfo) =>
            return if not classInfo

            for name, method of classInfo.methods
                continue if not method.override and not method.implementation
                continue if method.declaringStructure.name != classInfo.name

                range = new Range([method.startLine - 1, 0], [method.startLine, -1])

                @placeAnnotation(editor, range, @extractAnnotationInfo(method))

        failureHandler = () =>
            # Just do nothing.

        getClassListHandler = (classesInEditor) =>
            for name,classInfo of classesInEditor
                @service.getClassInfo(name).then(successHandler, failureHandler)

        @service.getClassListForFile(path).then(getClassListHandler, failureHandler)

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

        if context.override
            # NOTE: We deliberately show the declaring class here, not the structure (which could be a trait). However,
            # if the method is overriding a trait method from the *same* class, we show the trait name, as it would be
            # strange to put an annotation in "Foo" saying "Overrides method from Foo".
            overriddenFromFqcn = context.override.declaringClass.name

            if overriddenFromFqcn == context.declaringClass.name
                overriddenFromFqcn = context.override.declaringStructure.name

            extraData = context.override

            if not context.override.wasAbstract
                lineNumberClass = 'override'
                tooltipText = 'Overrides method from ' + overriddenFromFqcn

            else
                lineNumberClass = 'abstract-override'
                tooltipText = 'Implements abstract method from ' + overriddenFromFqcn

        else
            # NOTE: We deliberately show the declaring class here, not the structure (which could be a trait).
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
