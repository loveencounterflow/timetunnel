(function() {
  'use strict';
  var CND, IC, INTCODEC, badge, debug, echo, help, info, inspect, jr, rpr, test, urge, warn, whisper, xrpr, xrpr2;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'TIMETUNNEL/TESTS/INTCODEC';

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  info = CND.get_logger('info', badge);

  urge = CND.get_logger('urge', badge);

  help = CND.get_logger('help', badge);

  whisper = CND.get_logger('whisper', badge);

  echo = CND.echo.bind(CND);

  //...........................................................................................................
  test = require('guy-test');

  jr = JSON.stringify;

  IC = require('../..');

  ({inspect} = require('util'));

  xrpr = function(x) {
    return inspect(x, {
      colors: true,
      breakLength: 2e308,
      maxArrayLength: 2e308,
      depth: 2e308
    });
  };

  xrpr2 = function(x) {
    return inspect(x, {
      colors: true,
      breakLength: 20,
      maxArrayLength: 2e308,
      depth: 2e308
    });
  };

  //...........................................................................................................
  INTCODEC = require('../integer-codec');

  //-----------------------------------------------------------------------------------------------------------
  this["INTCODEC._convert() 1"] = async function(T, done) {
    var error, i, len, matcher, probe, probes_and_matchers;
    probes_and_matchers = [[["7", "0123456789", "01"], "111", null], [["0000003", "0123456789", "0123456789"], "3", null], [["000000", "0123456789", "ZOT"], "Z", null], [["8", "0123456789", "01"], "1000", null], [["7", "0123456789", "AB"], "BBB", null], [["8", "0123456789", "AB"], "BAAA", null], [["7", "0123456789", "ABC"], "CB", null], [["7", "0123456789", "𫝀𫝁𫝂"], "𫝂𫝁", null], [["21", "123", "123"], "21", null], [["𫝁𫝀", "𫝀𫝁𫝂", "123"], "21", null], [["25", "0123456789", "abcdefghijklmnopqrstuvwxyz"], "z", null], [["26", "0123456789", "abcdefghijklmnopqrstuvwxyz"], "ba", null], [["27", "0123456789", "abcdefghijklmnopqrstuvwxyz"], "bb", null]];
//.........................................................................................................
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher, error] = probes_and_matchers[i];
      await T.perform(probe, matcher, error, function() {
        return new Promise(function(resolve, reject) {
          var desttable, result, src, srctable;
          [src, srctable, desttable] = probe;
          result = INTCODEC._convert(src, srctable, desttable);
          // debug 'µ33348', result
          return resolve(result);
        });
      });
    }
    return done();
  };

  //-----------------------------------------------------------------------------------------------------------
  this["INTCODEC._convert() with errors"] = async function(T, done) {
    var error, i, len, matcher, probe, probes_and_matchers;
    probes_and_matchers = [[["7", "7878", "1234"], null, "expected a text with two or more distinct characters"], [["7", "0123456789", "x"], null, "expected a text with two or more characters"], [["7", "1234", "123"], null, "number contains illegal digits"], [["xxxxxxx", "yz", "0123456789"], null, "number contains illegal digits"], [["12", "3456789", ".;"], null, "number contains illegal digits"]];
//.........................................................................................................
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher, error] = probes_and_matchers[i];
      await T.perform(probe, matcher, error, function() {
        return new Promise(function(resolve, reject) {
          var desttable, result, src, srctable;
          [src, srctable, desttable] = probe;
          result = INTCODEC._convert(src, srctable, desttable);
          // debug 'µ33348', result
          return resolve(result);
        });
      });
    }
    return done();
  };

  //-----------------------------------------------------------------------------------------------------------
  this["INTCODEC.encode()"] = async function(T, done) {
    var error, i, len, matcher, probe, probes_and_matchers;
    probes_and_matchers = [[[512, '01'], '1000000000'], [[512, 'abcdefghijklmnopqrstuvwxyz'], 'ts']];
//.........................................................................................................
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher, error] = probes_and_matchers[i];
      await T.perform(probe, matcher, error, function() {
        return new Promise(function(resolve, reject) {
          var desttable, result, src, srctable;
          [src, srctable, desttable] = probe;
          result = INTCODEC.encode(src, srctable, desttable);
          // debug 'µ33348', result
          return resolve(result);
        });
      });
    }
    return done();
  };

  //-----------------------------------------------------------------------------------------------------------
  this["INTCODEC.decode()"] = async function(T, done) {
    var error, i, len, matcher, probe, probes_and_matchers;
    probes_and_matchers = [[['10000', '01'], 16], [['1000000000', '01'], 512]];
//.........................................................................................................
    for (i = 0, len = probes_and_matchers.length; i < len; i++) {
      [probe, matcher, error] = probes_and_matchers[i];
      await T.perform(probe, matcher, error, function() {
        return new Promise(function(resolve, reject) {
          var desttable, result, src, srctable;
          [src, srctable, desttable] = probe;
          result = INTCODEC.decode(src, srctable, desttable);
          // debug 'µ33348', result
          return resolve(result);
        });
      });
    }
    return done();
  };

  //###########################################################################################################
  if (module.parent == null) {
    test(this);
  }

  // test @[ "tunnels: hiding" ]
// test @[ "tunnels: hiding and revealing" ]

}).call(this);

//# sourceMappingURL=integer-codec.test.js.map