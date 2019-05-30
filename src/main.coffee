


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
  constructor: ( settings ) ->
    super()
    validate.timetunnel_settings settings
    @guards               = settings?.guards  ? '\x10\x11\x12\x13\x14'
    @intalph              = settings?.intalph ? '0123456789'
    ### TAINT reduplicates some tests, `Array.from()` calls ###
    validate.timetunnel_collisionfree_texts @guards, @intalph
    @guards               = Array.from @guards
    #.......................................................................................................
    @chr_count            = @guards.length
    @delta                = ( @chr_count + 1 ) / 2 - 1
    @master               = @guards[ @chr_count - @delta - 1 ]
    @meta_chr_patterns    = ( /// #{esc_re @guards[ idx ]} ///gu            for idx in [ 0 .. @delta ] )
    @target_seq_chrs      = ( "#{@master}#{@guards[ idx + @delta ]}"        for idx in [ 0 .. @delta ] )
    @target_seq_patterns  = ( /// #{esc_re @target_seq_chrs[ idx ]} ///gu for idx in [ 0 .. @delta ] )
    @cloaked              = @guards[ 0 ... @delta ]
    @reveal_pattern       = /// #{esc_re @cloaked[ 0 ]} ( [ #{esc_re @intalph} ]+ ) #{esc_re @cloaked[ 1 ]} ///gu
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
      R = R.replace @target_seq_patterns[ idx ], @guards[ idx ]
    return R

  #---------------------------------------------------------------------------------------------------------
  _hide_pattern: ( pattern, text ) =>
    R = text
    R = R.replace pattern, ( P... ) =>
      ### Choose entire match or first group: ###
      $1 = if ( P.length is 3 ) then P[ 0 ] else P[ 1 ]
      cache_idx_txt = @_store $1
      return "#{@cloaked[ 0 ]}#{cache_idx_txt}#{@cloaked[ 1 ]}"
    return R

  #---------------------------------------------------------------------------------------------------------
  _reveal_tunneled: ( text ) =>
    R = text
    while ( R.match @reveal_pattern )?
      R = R.replace @reveal_pattern, ( P... ) =>
        ### Choose entire match or first group: ###
        $1 = if ( P.length is 3 ) then P[ 0 ] else P[ 1 ]
        return @_retrieve $1
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
    return INTCODEC.encode R, @intalph

  #---------------------------------------------------------------------------------------------------------
  _retrieve: ( idx_txt ) ->
    idx = INTCODEC.decode idx_txt, @intalph
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






