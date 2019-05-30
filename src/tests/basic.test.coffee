

'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'TIMETUNNEL/TESTS/BASIC'
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
TIMETUNNEL                = require '../..'
# require '../exception-handler'

#-----------------------------------------------------------------------------------------------------------
@[ "basic escaping" ] = ( T, done ) ->
  probes_and_matchers = [
    [['abcde','abcdefghxyz'],'cccdcedefghxyz',null,]
    [['abc',null],null,'not a valid tunneltext_chrs',]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ chrs, text, ] = probe
      tnl = new TIMETUNNEL.Timetunnel chrs
      result = tnl.hide text
      resolve result
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "tunnels: hiding" ] = ( T, done ) ->
  probes_and_matchers = [
    [['abcde',['remove_backslash',], 'abcdefghxyz'],'cccdcedefghxyz',null,]
    [['abcde',['remove_backslash',], 'abc\\defghxyz'],'cccdcea0befghxyz',null,]
    [['abcde',['keep_backslash',], 'abc\\defghxyz'],'cccdcea0befghxyz',null,]
    [['abcde',['keep_backslash',], 'abc\\defgh\\xyz'],'cccdcea0befgha1byz',null,]
    [[null,['keep_backslash',], 'abc\\defgh\\xyz'],'abc\u00100\u0011efgh\u00101\u0011yz',null,]
    [['abcde',['remove_backslash','htmlish',], 'abc\\def <tag/> ghxyz'],'cccdcea0bef a1b ghxyz',null,]
    # [['abc',null],null,'not a valid tunneltext_chrs',]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ chrs, tunnel_names, text, ] = probe
      tnl = new TIMETUNNEL.Timetunnel chrs
      #.....................................................................................................
      for tunnel_name in tunnel_names
        tunnel_factory = TIMETUNNEL.tunnels[ tunnel_name ]
        tnl.add_tunnel tunnel_factory
      #.....................................................................................................
      result = tnl.hide text
      resolve result
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "tunnels: hiding and revealing" ] = ( T, done ) ->
  probes_and_matchers = [
    [['abcde',['remove_backslash',], 'abcdefghxyz'],'abcdefghxyz',null,]
    [['abcde',['remove_backslash',], 'abcdefghxyz'],'abcdefghxyz',null,]
    [['abcde',['keep_backslash',], 'abc\\defghxyz'],'abc\\defghxyz',null,]
    [[null,['keep_backslash',], 'abc\\defgh\\xyz'],'abc\\defgh\\xyz',null,]
    [['abcde',['remove_backslash','htmlish',], 'abc\\def <tag/> ghxyz'],'abcdef <tag/> ghxyz',null,]
    # [['abc',null],null,'not a valid tunneltext_chrs',]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ chrs, tunnel_names, text, ] = probe
      tnl = new TIMETUNNEL.Timetunnel chrs
      #.....................................................................................................
      for tunnel_name in tunnel_names
        tunnel_factory = TIMETUNNEL.tunnels[ tunnel_name ]
        tnl.add_tunnel tunnel_factory
      #.....................................................................................................
      result = tnl.reveal tnl.hide text
      resolve result
  done()



############################################################################################################
unless module.parent?
  test @
  # test @[ "tunnels: hiding" ]
  # test @[ "tunnels: hiding and revealing" ]


