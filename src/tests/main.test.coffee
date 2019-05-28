

'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'ICQL/TESTS/MAIN'
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
TUNNELTEXT                = require '../..'
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
      tnl = new TUNNELTEXT.Tunneltext chrs
      result = tnl.hide text
      resolve result
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "tunnels: hiding" ] = ( T, done ) ->
  probes_and_matchers = [
    [['abcde',['backslash',], 'abcdefghxyz'],'cccdcedefghxyz',null,]
    [['abcde',['backslash',], 'abc\\defghxyz'],'cccdceaB100befghxyz',null,]
    # [['abc',null],null,'not a valid tunneltext_chrs',]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ chrs, tunnel_names, text, ] = probe
      tnl = new TUNNELTEXT.Tunneltext chrs
      #.....................................................................................................
      for tunnel_name in tunnel_names
        tunnel_factory = TUNNELTEXT.tunnels[ tunnel_name ]
        tnl.add_tunnel tunnel_factory
      #.....................................................................................................
      result = tnl.hide text
      resolve result
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "tunnels: hiding and revealing" ] = ( T, done ) ->
  probes_and_matchers = [
    [['abcde',['backslash',], 'abcdefghxyz'],'abcdefghxyz',null,]
    [['abcde',['backslash',], 'abc\\defghxyz'],'abc\\defghxyz',null,]
    # [['abc',null],null,'not a valid tunneltext_chrs',]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ chrs, tunnel_names, text, ] = probe
      tnl = new TUNNELTEXT.Tunneltext chrs
      #.....................................................................................................
      for tunnel_name in tunnel_names
        tunnel_factory = TUNNELTEXT.tunnels[ tunnel_name ]
        tnl.add_tunnel tunnel_factory
      #.....................................................................................................
      result = tnl.reveal tnl.hide text
      resolve result
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "tunnels: hiding, reverting" ] = ( T, done ) ->
  probes_and_matchers = [
    [['abcde',['backslash',], 'abcdefghxyz'],'abcdefghxyz',null,]
    [['abcde',['backslash',], 'abc\\defghxyz'],'abcdefghxyz',null,]
    # [['abc',null],null,'not a valid tunneltext_chrs',]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ chrs, tunnel_names, text, ] = probe
      tnl = new TUNNELTEXT.Tunneltext chrs
      #.....................................................................................................
      for tunnel_name in tunnel_names
        tunnel_factory = TUNNELTEXT.tunnels[ tunnel_name ]
        tnl.add_tunnel tunnel_factory
      #.....................................................................................................
      result = tnl.revert tnl.hide text
      resolve result
  done()



############################################################################################################
unless module.parent?
  test @
  # test @[ "xxx" ]


