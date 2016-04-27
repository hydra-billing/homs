# This class deals with form definition object which comes from
# YML file deserialization

modulejs.define 'HBWFormDefinition', ['jQuery'], (jQuery) ->
  class Definition
    constructor: (@obj) ->
      @allFields = @getFields(@obj)

    fieldExist: (name) ->
      @allFields[name]

    # protected

    getFields: (obj) ->
      allFields = {}

      objFields = obj.fields || {}
      for field in objFields
        switch field.type
          when('group')          then jQuery.extend(allFields, @getFields(field))
          when('datetime_range') then jQuery.extend(allFields, @getDatetimeRangeFields(field))
          when('note')           then continue
          when('static')         then continue
          else allFields[field.name] = field

      allFields

    getDatetimeRangeFields: (obj) ->
      fields = {}
      fields[obj.from.name] = obj.from
      fields[obj.to.name]   = obj.to
      fields
