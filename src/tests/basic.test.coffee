

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


#-----------------------------------------------------------------------------------------------------------
@[ "basic escaping" ] = ( T, done ) ->
  probes_and_matchers = [
    [['abcde','abcdefghxyz'],'cccdcedefghxyz',null,]
    [['abc',null],null,'not a valid timetunnel_settings',]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ guards, text, ] = probe
      tnl = new TIMETUNNEL.Timetunnel { guards, }
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
    # [['abc',null],null,'not a valid timetunnel_guards',]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ guards, tunnel_names, text, ] = probe
      tnl = new TIMETUNNEL.Timetunnel { guards, }
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
    # [['abc',null],null,'not a valid timetunnel_guards',]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ guards, tunnel_names, text, ] = probe
      tnl = new TIMETUNNEL.Timetunnel { guards, }
      #.....................................................................................................
      for tunnel_name in tunnel_names
        tunnel_factory = TIMETUNNEL.tunnels[ tunnel_name ]
        tnl.add_tunnel tunnel_factory
      #.....................................................................................................
      result = tnl.reveal tnl.hide text
      resolve result
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "instantiation: errors" ] = ( T, done ) ->
  probes_and_matchers = [
    [['abcde','abc',],null,'not a valid timetunnel_collisionfree_texts',]
    ]
  #.........................................................................................................
  for [ probe, matcher, error, ] in probes_and_matchers
    await T.perform probe, matcher, error, -> return new Promise ( resolve, reject ) ->
      [ guards, intalph, ]  = probe
      tnl                   = new TIMETUNNEL.Timetunnel { guards, intalph, }
      resolve null
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "tunnels: grouping 1" ] = ( T, done ) ->
  transform = ( tnl, original_text, message ) ->
    tunneled_text   = tnl.hide    original_text
    modified_text   = modify      tunneled_text
    uncovered_text  = tnl.reveal  modified_text
    debug 'µ22129', '----------------------------'
    debug 'µ22129', message
    debug 'µ22129', '(1)', rpr original_text
    debug 'µ22129', '(2)', rpr tunneled_text
    debug 'µ22129', '(3)', rpr modified_text
    debug 'µ22129', '(4)', rpr uncovered_text
    return { tunneled_text, modified_text, uncovered_text, }
  #.........................................................................................................
  modify = ( text ) ->
    return text.replace /[0-9]+/g, ( $0 ) ->
      return '' + ( parseInt $0, 10 ) * 12
  #.........................................................................................................
  original_text = 'abcdeABCDE-CC-CD'
  #.........................................................................................................
  tnl = new TIMETUNNEL.Timetunnel { guards: 'abCDe', }
  tnl.add_tunnel ///   \{ ( [0-9]+ ) \}   ///gu
  t = transform tnl, original_text, "brackets not in group, removed"
  T.eq t.tunneled_text,  'CCCDcdeABCeDE-CeCe-CeD'
  T.eq t.modified_text,  'CCCDcdeABCeDE-CeCe-CeD'
  T.eq t.uncovered_text, 'abcdeABCDE-CC-CD'
  #.........................................................................................................
  tnl = new TIMETUNNEL.Timetunnel { guards: 'abCDe', }
  tnl.add_tunnel /// ( \{   [0-9]+   \} ) ///gu
  t = transform tnl, original_text, "brackets in group, not removed"
  T.eq t.tunneled_text,  'CCCDcdeABCeDE-CeCe-CeD'
  T.eq t.modified_text,  'CCCDcdeABCeDE-CeCe-CeD'
  T.eq t.uncovered_text, 'abcdeABCDE-CC-CD'
  #.........................................................................................................
  tnl = new TIMETUNNEL.Timetunnel { guards: 'abCDe', }
  tnl.add_tunnel /// \{   [0-9]+   \} ///gu
  t = transform tnl, original_text, "no group, equivalent to all grouped"
  T.eq t.tunneled_text,  'CCCDcdeABCeDE-CeCe-CeD'
  T.eq t.modified_text,  'CCCDcdeABCeDE-CeCe-CeD'
  T.eq t.uncovered_text, 'abcdeABCDE-CC-CD'
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "tunnels: grouping 2" ] = ( T, done ) ->
  transform = ( tnl, original_text, message ) ->
    tunneled_text   = tnl.hide    original_text
    modified_text   = modify      tunneled_text
    uncovered_text  = tnl.reveal  modified_text
    debug 'µ22129', '----------------------------'
    debug 'µ22129', message
    debug 'µ22129', '(1)', rpr original_text
    debug 'µ22129', '(2)', rpr tunneled_text
    debug 'µ22129', '(3)', rpr modified_text
    debug 'µ22129', '(4)', rpr uncovered_text
    return { tunneled_text, modified_text, uncovered_text, }
  #.........................................................................................................
  modify = ( text ) ->
    return text.replace /[0-9]+/g, ( $0 ) ->
      return '' + ( parseInt $0, 10 ) * 12
  #.........................................................................................................
  original_text = "abcde A plain number 123, two bracketed ones: {123}, {124}"
  guards        = 'abCDe'
  intalph       = '+-'
  #.........................................................................................................
  tnl = new TIMETUNNEL.Timetunnel { guards, intalph, }
  tnl.add_tunnel ///   \{ ( [0-9]+ ) \}   ///gu
  t = transform tnl, original_text, "brackets not in group, removed"
  T.eq t.tunneled_text,  'CCCDcde A plCCin numCDer 123, two CDrCCcketed ones: a+b, a-b'
  T.eq t.modified_text,  'CCCDcde A plCCin numCDer 1476, two CDrCCcketed ones: a+b, a-b'
  T.eq t.uncovered_text, 'abcde A plain number 1476, two bracketed ones: 123, 124'
  #.........................................................................................................
  tnl = new TIMETUNNEL.Timetunnel { guards, intalph, }
  tnl.add_tunnel /// ( \{   [0-9]+   \} ) ///gu
  t = transform tnl, original_text, "brackets in group, not removed"
  T.eq t.tunneled_text,  'CCCDcde A plCCin numCDer 123, two CDrCCcketed ones: a+b, a-b'
  T.eq t.modified_text,  'CCCDcde A plCCin numCDer 1476, two CDrCCcketed ones: a+b, a-b'
  T.eq t.uncovered_text, 'abcde A plain number 1476, two bracketed ones: {123}, {124}'
  #.........................................................................................................
  tnl = new TIMETUNNEL.Timetunnel { guards, intalph, }
  tnl.add_tunnel /// \{   [0-9]+   \} ///gu
  t = transform tnl, original_text, "no group, equivalent to all grouped"
  T.eq t.tunneled_text,  'CCCDcde A plCCin numCDer 123, two CDrCCcketed ones: a+b, a-b'
  T.eq t.modified_text,  'CCCDcde A plCCin numCDer 1476, two CDrCCcketed ones: a+b, a-b'
  T.eq t.uncovered_text, 'abcde A plain number 1476, two bracketed ones: {123}, {124}'
  #.........................................................................................................
  done()





############################################################################################################
unless module.parent?
  test @
  # test @[ "tunnels: hiding" ]
  # test @[ "tunnels: hiding and revealing" ]


