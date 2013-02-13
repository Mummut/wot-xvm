var settings = require("./settings").settings,
    utils = require("./utils"),
    db = require("./worker_db"),
    tcalc = require("./tcalc/tcalc");

exports.processCommand = function(response, args) {
    try {
        if (db.isOverloaded()) {
            response.statusCode = 503; // Service Unavailable
            throw "db overloaded";
        }

        var cmd = args.shift();
        if (!cmd)
            throw "empty command";

        var pl = args.shift();
        if (!pl)
            throw "[" + cmd + "]: empty player name";

        utils.log(cmd + ": " + pl + " " + args.join(","));

        switch (cmd) {
            case "INFO":
                cmd_INFO(response, pl, args);
                break;

            case "EFF":
            case "WN":
                cmd_EFF(response, pl, args);
                break;

            case "TWR":
                cmd_TWR(response, pl, args);
                break;

            case "XVMSCALE":
                cmd_XVMSCALE(response, pl, args);
                break;

            default:
                throw "Unknown command: " + cmd;
        }
    } catch(e) {
        response.end('{"error":"' + e + '","server":"' + settings.serverName + '"}');
    }
};

// PRIVATE

var cmd_INFO = function(response, pl, args) {
    var cursor = db.find("players", {$or:[{nm:pl},{_id:parseInt(pl)}]});
    cursor.toArray(function(error, data) {
        try {
            if(error)
                throw "[INFO]: MongoDB find error: " + error;
            var vn = args.shift();
//            utils.log(pl + "," + vn);
            if (vn) {
                vn = vn.toUpperCase();
                for (var id in data) {
                    var d = data[id];
                    for (var vname in d.v) {
                        if (vname == vn) {
                            var v = d.v[vname];
                            v.name = vname;
                            d.v = [ v ];
                            break;
                        }
                    }
                }
            }
            response.end(JSON.stringify(data));
        } catch(e) {
            response.end('{"error":"' + e + '","server":"' + settings.serverName + '"}');
        }
    });
};

var cmd_EFF = function(response, pl, args) {
    var cursor = db.find("players", {$or:[{nm:pl},{_id:parseInt(pl)}]});
    cursor.toArray(function(error, data) {
        try {
            if(error)
                response.end('[EFF]: MongoDB find error: ' + error);
            else if (data.length == 0)
                response.end('[EFF]: Player not found: ' + pl);
            else {
                var s = "";
                for (var i = 0; i < data.length; ++i) {
                    var start = new Date();
                    var d = data[i];
                    s += "<pre>";
                    s += "ID: " + d._id +
                        ", Nick: <a href='http://worldoftanks.ru/community/accounts/" + d._id + "-" + d.nm + "/'>" + d.nm + "</a>\n";
                    s += "--------------------------\n";
                    s += "LVL: " + d.lvl + "\n";
                    var eff = utils.calculateEfficiency(d);
                    s += "EFF: " + utils.calculateNEFF(eff) + " | " + eff + "\n";
                    var wn6 = utils.calculateWN(d);
                    s += "WN6: " + utils.calculateNWN(wn6) + " | " + wn6 + "\n";
                    s += "GWR: " + (d.w / d.b * 100).toFixed(2) + "%\n";
                    s += "TWR: " + tcalc.calc(d, false).result.toFixed(2) + "%\n";
                    s += "--------------------------\n";
                    s += "battles: " + d.b + "\n";
                    s += "wins: " + d.w + "\n";
                    s += "hit_percent: " + d.hip + "%\n";
                    s += "damage: " + d.dmg + " (" + (d.dmg / d.b).toFixed(0) + ")\n";
                    s += "frags: " + d.frg + " (" + (d.frg / d.b).toFixed(1) + ")\n";
                    s += "spotted: " + d.spo + " (" + (d.spo / d.b).toFixed(1) + ")\n";
                    s += "defence: " + d.def + " (" + (d.def / d.b).toFixed(1) + ")\n";
                    s += "capture: " + d.cap + " (" + (d.cap / d.b).toFixed(1) + ")\n";
                    s += "--------------------------\n";
                    s += "created: " + (new Date(d.cr * 1000)) + "\n";
                    s += "updated: " + (new Date(d.up * 1000)) + "\n";
                    s += "cached:  " + d.dt + "\n";
                    s += "--------------------------\n";
                    s += "duration: " + (new Date() - start) + " ms\n";
                    s += "</pre><hr>";
                }
                response.end(s);
            }
        } catch(e) {
            response.end('{"error":"' + e + '","server":"' + settings.serverName + '"}');
        }
    });
};

var cmd_TWR = function(response, pl, args) {
    var cursor = db.find("players", {nm: pl});
    cursor.toArray(function(error, data) {
        try {
            if(error)
                response.end('[TWR]: MongoDB find error: ' + error);
            else if (data.length == 0)
                response.end('[TWR]: Player not found: ' + pl);
            else {
                var s = "";
                for (var i = 0; i < data.length; ++i)
                    s += "<pre>" + tcalc.calc(data[i], true).log + "</pre><hr>";
                response.end(s);
            }
        } catch(e) {
            response.end('{"error":"' + e + '","server":"' + settings.serverName + '"}');
        }
    });
};

var cmd_XVMSCALE = function(response, pl, args) {
    var value = parseInt(pl);
    var s = "<pre>";
    s += "XEFF: " + utils.calculateNEFF(value) + " (" + value + ")\n";
    s += "XWN:  " + utils.calculateNWN(value) + " (" + value + ")\n";
    s += "</pre>"
    response.end(s);
};
