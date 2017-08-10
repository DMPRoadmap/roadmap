/*
  define is an utility to avoid namespace collisions. This function assumes that the root is dmproadmap.
  The local names are visited and constructed if they do not exist to return the context
  object of the last local name specified in the String. 
  The string has to be separated by '.' and currently there are no restrictions for local names
  (e.g. empty strings) are allowed.
  @param value String value representing a fully namespace
  @return The last local name context from the hierarchy of objects

  Usage: define('dmproadmap.a.b.c.d') will return the context of d by creating the following hierarchy if
  does not exist:
    dmproadmap: {
      a: {
        b: {
          c: {
            d: {}
          }
        }
      }
    }
*/
var define=function(value){
    var root='dmproadmap';
    if(Object.prototype.toString.call(value) === '[object String]'){
        var arrayNs=value.split('.');
      var restNs;
      if(arrayNs[0] === root){
        var restNs=arrayNs.slice(1);
        return restNs.reduce(function(ns, value){
            if(!ns[value]) return ns[value]={};
          return ns[value];
        }, window[root] = window[root] || {});
      }
    }
};