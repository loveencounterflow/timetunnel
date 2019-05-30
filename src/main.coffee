


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
rainbow                   = CND.rainbow.bind CND
{ jr, }                   = CND
Multimix                  = require 'multimix'
INTCODEC                  = require './integer-codec'
#...........................................................................................................
types                     = require './types'
{ isa
  validate
  declare
  size_of
  type_of }               = types



#-----------------------------------------------------------------------------------------------------------
### from https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions ###
esc_re = ( text ) -> text.replace /[.*+?^${}()|[\]\\]/g, "\\$&"


#===========================================================================================================
class @Timetunnel extends Multimix
  # @extend   object_with_class_properties
  # @include require './cataloguing'

  #---------------------------------------------------------------------------------------------------------
  constructor: ( chrs = null ) ->
    super()
    chrs                 ?= '\x10\x11\x12\x13\x14'
    validate.timetunnel_chrs chrs
    @chrs                 = Array.from chrs
    #.......................................................................................................
    @chr_count            = @chrs.length
    @delta                = ( @chr_count + 1 ) / 2 - 1
    @master               = @chrs[ @chr_count - @delta - 1 ]
    @meta_chr_patterns    = ( /// #{esc_re @chrs[ idx ]} ///gu            for idx in [ 0 .. @delta ] )
    @target_seq_chrs      = ( "#{@master}#{@chrs[ idx + @delta ]}"        for idx in [ 0 .. @delta ] )
    @target_seq_patterns  = ( /// #{esc_re @target_seq_chrs[ idx ]} ///gu for idx in [ 0 .. @delta ] )
    @cloaked              = @chrs[ 0 ... @delta ]
    @reveal_pattern       = /// #{esc_re @cloaked[ 0 ]} ( [ 0-9 ]+ ) #{esc_re @cloaked[ 1 ]} ///gu
    @tunnels              = []
    @_cache               = []
    @_index               = {}

  #---------------------------------------------------------------------------------------------------------
  hide: ( text ) ->
    R = text
    for idx in [ @delta .. 0 ] by -1
      R = R.replace @meta_chr_patterns[ idx ], @target_seq_chrs[ idx ]
    for pattern in @tunnels
      R = @_hide_pattern pattern, R
    return R

  #---------------------------------------------------------------------------------------------------------
  reveal: ( text ) ->
    R = text
    R = @_reveal_tunneled R
    for idx in [ 0 .. @delta ] by +1
      R = R.replace @target_seq_patterns[ idx ], @chrs[ idx ]
    return R

  #---------------------------------------------------------------------------------------------------------
  _hide_pattern: ( pattern, text ) =>
    R = text
    R = R.replace pattern, ( _, $1 ) =>
      cache_idx     = @_store $1
      cache_idx_txt = INTCODEC.encode cache_idx, 'ÄÖ'
      return "#{@cloaked[ 0 ]}#{cache_idx_txt}#{@cloaked[ 1 ]}"
    return R

  #---------------------------------------------------------------------------------------------------------
  _reveal_tunneled: ( text ) =>
    R = text
    while ( R.match @reveal_pattern )?
      R = R.replace @reveal_pattern, ( _, $1 ) => @_retrieve INTCODEC.decode $1, 'ÄÖ'
    return R

  #---------------------------------------------------------------------------------------------------------
  add_tunnel: ( pattern ) ->
    validate.timetunnel_tunnel_pattern pattern
    @tunnels.push pattern


  #=========================================================================================================
  # CACHE
  #---------------------------------------------------------------------------------------------------------
  _store: ( x ) ->
    return R if ( R = @_index[ x ] )?
    R             = @_cache.length
    @_index[ x ]  = R
    @_cache.push x
    return R

  #---------------------------------------------------------------------------------------------------------
  _retrieve: ( idx ) ->
    unless ( idx >= 0 ) and ( idx < @_cache.length )
      throw new Error "µ44292 index out of bounds, got #{rpr idx}"
    return @_cache[ idx ]


#===========================================================================================================
# TUNNELS
#-----------------------------------------------------------------------------------------------------------
@tunnels =
  remove_backslash:   /// \\ ( . ) ///gu
  keep_backslash:     /// ( \\ . ) ///gu
  htmlish:            /// ( < [^>]*? > ) ///gu






