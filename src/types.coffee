


'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'TIMETUNNEL/TYPES'
debug                     = CND.get_logger 'debug',     badge
alert                     = CND.get_logger 'alert',     badge
whisper                   = CND.get_logger 'whisper',   badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
info                      = CND.get_logger 'info',      badge
jr                        = JSON.stringify
Intertype                 = ( require 'intertype' ).Intertype
intertype                 = new Intertype module.exports

#-----------------------------------------------------------------------------------------------------------
@declare 'timetunnel_distinctive_nonempty_chrs',
  tests:
    "x is a text":                          ( x ) -> @isa.text x
    "x has 1 or more distinct codepoints":  ( x ) ->
      size = @size_of new Set Array.from x
      return ( size > 0 ) and ( size is ( @size_of x, 'codepoints' ) )

#-----------------------------------------------------------------------------------------------------------
@declare 'timetunnel_chrs',
  tests:
    "x is a text":                  ( x ) -> @isa.text x
    "x has 5 distinct codepoints":  ( x ) -> ( new Set Array.from x ).size is 5

#-----------------------------------------------------------------------------------------------------------
@declare 'timetunnel_tunnel_pattern',
  tests:
    "x is a regex":                 ( x ) -> @isa.regex x
    "x has global flag":            ( x ) -> 'g' in x.flags


