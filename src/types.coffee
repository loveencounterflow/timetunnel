


'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'TUNNELTEXT/TYPES'
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
@declare 'tunneltext_chrs',
  tests:
    "x is a text":                  ( x ) -> @isa.text x
    "x has 5 distinct codepoints":  ( x ) -> ( new Set Array.from x ).size is 5

#-----------------------------------------------------------------------------------------------------------
@declare 'tunneltext_tunnel_factory',
  tests:
    "x is a function":              ( x ) -> @isa.function x
    "arity of x is 1":              ( x ) -> x.length is 1

#-----------------------------------------------------------------------------------------------------------
@declare 'tunneltext_tunnel',
  tests:
    "x is an object":               ( x ) -> @isa.object x
    "x.name is a nonempty text":    ( x ) -> @isa.nonempty_text x.name
    "x.hide is a function":         ( x ) -> @isa.function x.hide
    "x.reveal is a function":       ( x ) -> @isa.function x.reveal
    "x.remove may be a function":   ( x ) -> ( not x.remove? ) or ( @isa.function x.remove )
    "arity of x.hide is 1":         ( x ) -> x.hide.length is 1
    "arity of x.reveal is 1":       ( x ) -> x.reveal.length is 1
    "arity of x.remove is 1":       ( x ) -> ( not x.remove? ) or ( x.remove.length is 1 )

