

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
@[ "xxx" ] = ( T, done ) ->
  probes_and_matchers = [
    [['abcde','abcdefghxyz'],'cccdcedefghxyz',null,]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ chrs, text, ] = probe
      tnl = new TUNNELTEXT.Tunneltext chrs
      result = tnl.hide text
      # try
      # result = await IC.read_definitions_from_text probe
      # catch error
      #   return resolve error
      # debug '29929', xrpr2 result
      # resolve result
      resolve result
  done()



############################################################################################################
unless module.parent?
  test @
  # test @[ "xxx" ]


