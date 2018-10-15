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

    // protected

    getFields (obj) {
      const allFields = {};

      const objFields = obj.fields || {};
      for (const field of Array.from(objFields)) {
        switch (field.type) {
          case ('group'): jQuery.extend(allFields, this.getFields(field)); break;
          case ('datetime_range'): jQuery.extend(allFields, this.getDatetimeRangeFields(field)); break;
          case ('note'): continue; break;
          case ('static'): continue; break;
          default: allFields[field.name] = field;
        }
      }

      return allFields;
    }

    getDatetimeRangeFields (obj) {
      const fields = {};
      fields[obj.from.name] = obj.from;
      fields[obj.to.name] = obj.to;
      return fields;
    }
  }

  return Definition;
});
