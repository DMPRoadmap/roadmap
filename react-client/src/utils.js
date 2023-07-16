
export function getValue(obj, path, defaultNone) {
  if (typeof defaultNone === 'undefined') defaultNone = "";
  if (typeof path === 'string') path = path.split(".");

  if (path.length === 0) throw "Path Length is Zero";
  if (path.length === 1) return obj[path[0]];

  if (!obj[path[0]]) return defaultNone;
  return getValue(obj[path[0]], path.slice(1));
};
