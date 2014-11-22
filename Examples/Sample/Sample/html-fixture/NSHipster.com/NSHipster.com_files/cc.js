(function(){

  var i = new Image();

  var params = '?url=' + encodeURIComponent(window.location.href);
  if (typeof Swiftype !== 'undefined' && typeof Swiftype.key !== 'undefined') {
    params += '&engine_key=' + Swiftype.key;
  }
  if (document.referrer != "") { params += "&r=" + encodeURIComponent(document.referrer); }

  i.src = "//cc.swiftype.com/cc" + params;
})();
