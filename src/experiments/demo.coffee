


"use strict"

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'TIMETUNNEL/MAIN'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND

#--------------------------------------------------------
# Create a TimeTunnel instance:

log             = console.log
rpr             = ( require 'util' ).inspect
TIMETUNNEL      = require '../..'
# TIMETUNNEL      = require 'timetunnel'
# tnl.add_tunnel TIMETUNNEL.tunnels.remove_backslash
# tnl.add_tunnel TIMETUNNEL.tunnels.htmlish

#--------------------------------------------------------
modify = ( text ) ->
  return text.replace /[0-9]+/g, ( $0 ) ->
    return '' + ( parseInt $0, 10 ) * 12

#--------------------------------------------------------
original_text = "abCD* A plain number 123, two bracketed ones: {123}, {124}"

#--------------------------------------------------------
# Hide 'offending' original_text,
# process it,
# finally recover tunneled parts:

transform = ( tnl, original_text, message ) ->
  tunneled_text   = tnl.hide    original_text
  modified_text   = modify      tunneled_text
  uncovered_text  = tnl.reveal  modified_text
  log '----------------------------'
  log message
  log '(1)', rpr original_text
  log '(2)', rpr tunneled_text
  log '(3)', rpr modified_text
  log '(4)', rpr uncovered_text
  return uncovered_text

tnl = new TIMETUNNEL.Timetunnel { guards: 'abCD*', intalph: '-|' }
tnl.add_tunnel ///   \{ ( [0-9]+ ) \}   ///gu
transform tnl, original_text, "brackets not in group, removed"

tnl = new TIMETUNNEL.Timetunnel { guards: 'abCD*', intalph: '-|' }
tnl.add_tunnel /// ( \{   [0-9]+   \} ) ///gu
transform tnl, original_text, "brackets in group, not removed"

tnl = new TIMETUNNEL.Timetunnel { guards: 'abCD*', intalph: '-|' }
tnl.add_tunnel /// \{   [0-9]+   \} ///gu
transform tnl, original_text, "no group, equivalent to all grouped"

# tnl = new TIMETUNNEL.Timetunnel { guards: 'abCD*', intalph: 'ab' }
# tnl.add_tunnel ///   \{ ( [0-9]+ ) \}   ///gu
# transform tnl, original_text, "brackets not in group, removed"

# tnl = new TIMETUNNEL.Timetunnel { guards: 'abCD*', intalph: 'CD' }
# tnl.add_tunnel ///   \{ ( [0-9]+ ) \}   ///gu
# transform tnl, original_text, "brackets not in group, removed"

# tnl = new TIMETUNNEL.Timetunnel { guards: 'abCD*', intalph: 'D*' }
# tnl.add_tunnel ///   \{ ( [0-9]+ ) \}   ///gu
# transform tnl, original_text, "brackets not in group, removed"



gs = [
  'abcde'
  'abCDE'
  'abCD*'
  'ABcde'
  '()CDE' ]
text = 'abcdeABCDE-CC-CD'
for guards in gs
  tnl = new TIMETUNNEL.Timetunnel { guards, }
  log ( rpr guards ), ( rpr text ), '->', ( rpr tnl.hide text )



