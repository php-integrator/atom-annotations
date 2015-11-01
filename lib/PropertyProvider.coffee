AbstractProvider = require './AbstractProvider'

module.exports =

##*
# Provides annotations for member properties that are overrides.
##
class PropertyProvider extends AbstractProvider
    ###*
     * @inheritdoc
    ###
    regex: /(\s*(?:public|protected|private)\s+\$)(\w+)\s+/g

    ###*
     * @inheritdoc
    ###
    extractAnnotationInfo: (editor, row, rowText, match) ->
        currentClass = @service.determineFullClassName(editor)

        propertyName = match[2]

        context = @service.getClassProperty(currentClass, propertyName)

        if not context or not context.override
            return null

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
        atom.workspace.open(annotationInfo.extraData.declaringStructure.filename, {
            # initialLine    : annotationInfo.startLine - 1,
            searchAllPanes : true
        })
