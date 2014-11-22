var Swiftype = window.Swiftype || {};
Swiftype.root_url = Swiftype.root_url || "//api.swiftype.com";
Swiftype.embedVersion = Swiftype.embedVersion || 'v1';
if (typeof Swiftype.renderStyle === 'undefined') {
  Swiftype.renderStyle = 'nocode';
}

Swiftype.isMobile = function() {
  var ua = window.navigator.userAgent;
  if(/iPhone|iPod/.test(ua) && ua.indexOf("AppleWebKit") > -1 ) {
    return true;
  }
  if (/Android/.test(ua) && /Mobile/i.test(ua) && ua.indexOf("AppleWebKit") > -1 ) {
    return true;
  }
  return false;
};

Swiftype.loadScript = function(url, callback) {
  var script = document.createElement('script');
  script.type = 'text/javascript';
  script.async = true;
  script.src = url;

  var entry = document.getElementsByTagName('script')[0];
  entry.parentNode.insertBefore(script, entry);

  if (script.addEventListener) {
    script.addEventListener('load', callback, false);
  } else {
    script.attachEvent('onreadystatechange', function() {
      if (/complete|loaded/.test(script.readyState))
        callback();
    });
  }
};

Swiftype.loadStylesheet = function(url) {
  var link = document.createElement('link');
  link.rel = 'stylesheet';
  link.type = 'text/css';
  link.href = url;
  (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(link);
};

Swiftype.loadSupportingFiles = function(callback) {
  if (Swiftype.renderStyle === false) {
    Swiftype.loadScript("//s.swiftypecdn.com/assets/swiftype_no_render-6c64754ae91a4333da44d1dd74482f76.js", callback);
    Swiftype.loadStylesheet("//s.swiftypecdn.com/assets/swiftype-9261e170d74ef8347d54dc5ba07098ad.css");
  } else if (Swiftype.isMobile() && !Swiftype.disableMobileOverlay) {
    Swiftype.loadScript("//s.swiftypecdn.com/assets/swiftype_nocode-07cbc4b36e68587ab665b0b38990d144.js", callback);
    Swiftype.loadStylesheet("//s.swiftypecdn.com/assets/swiftype_nocode-c3886df84f1fbe6c1177c96bbf4a40ac.css");
  } else if (Swiftype.renderStyle === 'inline' || Swiftype.renderStyle === 'new_page') {
    Swiftype.loadScript("//s.swiftypecdn.com/assets/swiftype_onpage-3af7306276568b2e98812313e55587e3.js", callback);
    Swiftype.loadStylesheet("//s.swiftypecdn.com/assets/swiftype-9261e170d74ef8347d54dc5ba07098ad.css");
  } else {
    Swiftype.loadScript("//s.swiftypecdn.com/assets/swiftype_nocode-07cbc4b36e68587ab665b0b38990d144.js", callback);
    Swiftype.loadStylesheet("//s.swiftypecdn.com/assets/swiftype_nocode-c3886df84f1fbe6c1177c96bbf4a40ac.css");
  }
};

var Swiftype = (function(window, undefined) {
   if (Swiftype.embedVersion === 'v1') {
     Swiftype.loadSupportingFiles(function(){});
   }
   return Swiftype;
})(window);
