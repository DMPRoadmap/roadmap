import { useState, useEffect } from "react";

export function truncateText(text, maxLength) {
  if (text.length > maxLength) {
    return text.slice(0, maxLength) + "...";
  } else {
    return text;
  }
}

export function isEmpty(obj) {
  for (const prop in obj) {
    if (Object.hasOwn(obj, prop)) {
      return false;
    }
  }
  return true;
}

export function getValue(obj, path, defaultNone) {
  if (!obj) return defaultNone;

  if (typeof defaultNone === "undefined") defaultNone = "";
  if (typeof path === "string") path = path.split(".");

  if (path.length === 0) throw "Path Length is Zero";

  if ((obj[path[0]] === null) || (typeof obj[path[0]] === 'undefined')) {
    return defaultNone;
  }

  if (path.length === 1) { return obj[path[0]]; }

  return getValue(obj[path[0]], path.slice(1), defaultNone);
}


export function setProperty(obj, path, value) {
  const [head, ...rest] = path.split('.')
  return {
    ...obj,
    [head]: rest.length
      ? setProperty(obj[head], rest.join('.'), value)
      : value
  }
}


export const fileSizeUnits = ["Bytes", "KB", "MB", "GB", "TB"];

export function formatBytes(bytes, decimals) {
  if(bytes == 0) return {value: 0, unit: 'Bytes'};
  var k = 1024,
      dm = decimals || 2,
      i = Math.floor(Math.log(bytes) / Math.log(k));
  return {
    value: parseFloat((bytes / Math.pow(k, i)).toFixed(dm)),
    unit: fileSizeUnits[i],
  };
}

export function convertToBytes(value, unit) {
    let bytes = 0;
    switch (unit.toLowerCase()) {
        case 'tb':
            bytes = value * Math.pow(1024, 4);
            break;
        case 'gb':
            bytes = value * Math.pow(1024, 3);
            break;
        case 'mb':
            bytes = value * Math.pow(1024, 2);
            break;
        case 'kb':
            bytes = value * 1024;
            break;
        default:
            bytes = value;
    }
    return bytes;
}

export function useDebounce(val, delay) {
  const [debouncedValue, setDebouncedValue] = useState(val);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(val);
    }, delay);

    return () => {
      clearTimeout(handler);
    };
  }, [val]);

  return debouncedValue;
}
