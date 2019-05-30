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
original_text = "abcde A plain number 123, two bracketed ones: {123}, {124}"

#--------------------------------------------------------
# Hide 'offending' original_text,
# process it,
# finally recover tunneled parts:

transform = ( tnl, original_text ) ->
  tunneled_text   = tnl.hide    original_text
  modified_text   = modify      tunneled_text
  uncovered_text  = tnl.reveal  modified_text
  log '(1)', rpr original_text
  log '(2)', rpr tunneled_text
  log '(3)', rpr modified_text
  log '(4)', rpr uncovered_text
  return uncovered_text

tnl = new TIMETUNNEL.Timetunnel 'abcde'
tnl.add_tunnel ///   \{ ( [0-9]+ ) \}   ///gu
transform tnl, original_text

log '...'

tnl = new TIMETUNNEL.Timetunnel 'abcde'
tnl.add_tunnel /// ( \{   [0-9]+   \} ) ///gu
transform tnl, original_text

log '...'

tnl = new TIMETUNNEL.Timetunnel()
tnl.add_tunnel /// ( \{   [0-9]+   \} ) ///gu
transform tnl, original_text


