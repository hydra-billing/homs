// This class deals with form definition object which comes from
// YML file deserialization

modulejs.define('HBWFormDefinition', ['jQuery'], (jQuery) => {
  class Definition {
    constructor (obj) {
      this.obj = obj;
      this.allFields = this.getFields(this.obj);
    }

    fieldExist (name) {
      return this.allFields[name];
    }

    getFields (obj) {
      const allFields = {};
      const objFields = obj.fields || {};

      [...objFields].forEach((field) => {
        switch (field.type) {
          case ('group'): jQuery.extend(allFields, this.getFields(field)); break;
          case ('datetime_range'): jQuery.extend(allFields, Definition.getDatetimeRangeFields(field)); break;
          case ('note'): break;
          case ('static'): break;
          default: allFields[field.name] = field;
        }
      });

      return allFields;
    }

    static getDatetimeRangeFields (obj) {
      const fields = {};

      fields[obj.from.name] = obj.from;
      fields[obj.to.name] = obj.to;

      return fields;
    }
  }

  return Definition;
});
