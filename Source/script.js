
var script = new function() {
    this.getLink = function(x,y) {
        var tags = "";
        var e = "";
        var offset = 0;
        while ((tags.length == 0) && (offset < 20)) {
            e = document.elementFromPoint(x,y+offset);
            while (e) {
                if (e.href) {
                    tags += e.href;
                    break;
                }
                e = e.parentNode;
            }
            if (tags.length == 0) {
                e = document.elementFromPoint(x,y-offset);
                while (e) {
                    if (e.href) {
                        tags += e.href;
                        break;
                    }
                    e = e.parentNode;
                }
            }
            offset++;
        }
        return tags;
    }
}