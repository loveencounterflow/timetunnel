

'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'TIMETUNNEL/TESTS/INTCODEC'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
info                      = CND.get_logger 'info',      badge
urge                      = CND.get_logger 'urge',      badge
help                      = CND.get_logger 'help',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
#...........................................................................................................
test                      = require 'guy-test'
jr                        = JSON.stringify
IC                        = require '../..'
{ inspect, }              = require 'util'
xrpr                      = ( x ) -> inspect x, { colors: yes, breakLength: Infinity, maxArrayLength: Infinity, depth: Infinity, }
xrpr2                     = ( x ) -> inspect x, { colors: yes, breakLength: 20, maxArrayLength: Infinity, depth: Infinity, }
#...........................................................................................................
INTCODEC                  = require '../integer-codec'
# require '../exception-handler'

#-----------------------------------------------------------------------------------------------------------
@[ "INTCODEC._convert() 1" ] = ( T, done ) ->
  probes_and_matchers = [
    [["7","0123456789","01"],"111",null]
    [["0000003","0123456789","0123456789"],"3",null]
    [["000000","0123456789","ZOT"],"Z",null]
    [["8","0123456789","01"],"1000",null]
    [["7","0123456789","AB"],"BBB",null]
    [["8","0123456789","AB"],"BAAA",null]
    [["7","0123456789","ABC"],"CB",null]
    [["7","0123456789","𫝀𫝁𫝂"],"𫝂𫝁",null]
    [["21","123","123"],"21",null]
    [["𫝁𫝀","𫝀𫝁𫝂","123"],"21",null]
    [["25","0123456789","abcdefghijklmnopqrstuvwxyz"],"z",null]
    [["26","0123456789","abcdefghijklmnopqrstuvwxyz"],"ba",null]
    [["27","0123456789","abcdefghijklmnopqrstuvwxyz"],"bb",null]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ src, srctable, desttable, ] = probe
      result = INTCODEC._convert src, srctable, desttable
      # debug 'µ33348', result
      resolve result
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "INTCODEC._convert() with errors" ] = ( T, done ) ->
  probes_and_matchers = [
    [["7","7878","1234"],null,"expected a text with two or more distinct characters"]
    [["7","0123456789","x"],null,"expected a text with two or more characters"]
    [["7","1234","123"],null,"number contains illegal digits"]
    [["xxxxxxx","yz","0123456789"],null,"number contains illegal digits"]
    [["12","3456789",".;"],null,"number contains illegal digits"]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ src, srctable, desttable, ] = probe
      result = INTCODEC._convert src, srctable, desttable
      # debug 'µ33348', result
      resolve result
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "INTCODEC.encode()" ] = ( T, done ) ->
  probes_and_matchers = [
    [[ 512,'01'],'1000000000']
    [[ 512,'abcdefghijklmnopqrstuvwxyz'],'ts']
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ src, srctable, desttable, ] = probe
      result = INTCODEC.encode src, srctable, desttable
      # debug 'µ33348', result
      resolve result
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "INTCODEC.decode()" ] = ( T, done ) ->
  probes_and_matchers = [
    [[ '10000','01'], 16]
    [[ '1000000000','01'], 512]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ src, srctable, desttable, ] = probe
      result = INTCODEC.decode src, srctable, desttable
      # debug 'µ33348', result
      resolve result
  done()




############################################################################################################
unless module.parent?
  test @
  # test @[ "tunnels: hiding" ]
  # test @[ "tunnels: hiding and revealing" ]


