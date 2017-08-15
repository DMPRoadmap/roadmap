(function(ctx){  
  var vals = {
    PASSWORD_MIN_LENGTH: 8,
    PASSWORD_MAX_LENGTH: 128
  };

  for(var key in vals){
    ctx[key] = ctx[key] || vals[key];
  }
})(define('dmproadmap.constants'));
