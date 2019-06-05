var CustomFormatter = {
  getNextValForAdd(prevVal, nextVal, position, pattern) {
    var updatedNextVal;

    if (prevVal[position] == ' ' && nextVal.length <= pattern.length) {
      updatedNextVal = prevVal.substr(0, position) + nextVal[position] + prevVal.substr(position + 1, prevVal.length);
    } else {
      updatedNextVal = prevVal;
    }

    return updatedNextVal;
  },

  simplifyMask(mask, templateRegexp) {
    var matches = mask.match(templateRegexp);
    var simpleMask = mask;

    matches.forEach((_match) => {
      const newPart = _match.replace('{{', '').replace('}}', '').replace(/9/g, '_');
      simpleMask = simpleMask.replace(_match, newPart);
    });

    return simpleMask;
  },

  applyMaskForValue(mask, value, templateRegexp) {
    var simpleMask = CustomFormatter.simplifyMask(mask, templateRegexp);

    if (value.length > simpleMask.length) {
      return [value, value.length];
    } else {
      var i = 0;
      var def = simpleMask.replace(/\D/g, "");
      var val = value.replace(/\D/g, "");
      if (def.length >= val.length)
        val = def;

      simpleMask = simpleMask.replace(/[_\d]/g, function (_) {
        return val.charAt(i++) || "_";
      });

      i = simpleMask.indexOf("_");

      if (i < 0)
        i = simpleMask.length;

      return {mask: simpleMask.replace(/_/g, ' '), position: i}
    }
  },

  getNextValForRemove(pattern, templateRegexp, position, nextVal) {
    var simpleMask = CustomFormatter.simplifyMask(pattern, templateRegexp);
    var updatedNextVal = nextVal;

    if (simpleMask[position - 1] == '_') {
      updatedNextVal = updatedNextVal.substr(0, position - 1) + ' ' + updatedNextVal.substr(position + 1, updatedNextVal.length)
    } else {
      var arr = Array.apply(null, {length: position - 1}).map(Number.call, Number).reverse();

      for (const el of arr) {
        if (simpleMask[el] === '_') {
          updatedNextVal = updatedNextVal.substr(0, el) + ' ' + updatedNextVal.substr(el + 1, updatedNextVal.length);
          break;
        }
      }
    }

    return updatedNextVal
  }
};

export default CustomFormatter;
