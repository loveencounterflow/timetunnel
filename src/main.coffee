


"use strict"

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'TUNNELTEXT/MAIN'
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
class @Tunneltext extends Multimix
  # @extend   object_with_class_properties
  # @include require './cataloguing'
  # @include require './sizing'
  # @include require './declaring'

  #---------------------------------------------------------------------------------------------------------
  constructor: ( chrs = '\x10\x11\x12\x13\x14' ) ->
    super()
    validate.tunneltext_chrs chrs
    @chrs                 = Array.from chrs
    #.......................................................................................................
    @chr_count            = @chrs.length
    @delta                = ( @chr_count + 1 ) / 2 - 1
    @master               = @chrs[ @chr_count - @delta - 1 ]
    @meta_chr_patterns    = ( /// #{esc_re @chrs[ idx ]} ///gu            for idx in [ 0 .. @delta ] )
    @target_seq_chrs      = ( "#{@master}#{@chrs[ idx + @delta ]}"        for idx in [ 0 .. @delta ] )
    @target_seq_patterns  = ( /// #{esc_re @target_seq_chrs[ idx ]} ///gu for idx in [ 0 .. @delta ] )
    @cloaked              = @chrs[ 0 ... @delta ]
    @tunnels              = []

    # debug 'µhd', '@delta:                ', rpr @delta
    # debug 'µhd', '@master:               ', rpr @master
    # debug 'µhd', '@meta_chr_patterns:    ', rpr @meta_chr_patterns
    # debug 'µhd', '@target_seq_chrs:      ', rpr @target_seq_chrs
    # debug 'µhd', '@target_seq_patterns:  ', rpr @target_seq_patterns
    # debug 'µhd', '@cloaked:              ', rpr @cloaked

  #---------------------------------------------------------------------------------------------------------
  hide: ( text ) ->
    R = text
    for idx in [ @delta .. 0 ] by -1
      R = R.replace @meta_chr_patterns[ idx ], @target_seq_chrs[ idx ]
    for tunnel in @tunnels
      R = tunnel.hide R
    return R

  #---------------------------------------------------------------------------------------------------------
  reveal: ( text ) ->
    R = text
    for idx in [ @tunnels.length - 1 .. 0 ] by -1
      R = @tunnels[ idx ].reveal R
    for idx in [ 0 .. @delta ] by +1
      R = R.replace @target_seq_patterns[ idx ], @chrs[ idx ]
    return R

  #---------------------------------------------------------------------------------------------------------
  revert: ( text ) ->
    R = @reveal text
    for idx in [ @tunnels.length - 1 .. 0 ] by -1
      continue unless ( tunnel = @tunnels[ idx ] ).remove?
      R = tunnel.remove R
    return R

  #---------------------------------------------------------------------------------------------------------
  _cache:   []
  _index:   {}

  #---------------------------------------------------------------------------------------------------------
  store: ( x ) ->
    return R if ( R = @_index[ x ] )?
    R             = @_cache.length
    @_index[ x ]  = R
    @_cache.push x
    return R

  #---------------------------------------------------------------------------------------------------------
  retrieve: ( idx ) ->
    unless ( idx >= 0 ) and ( idx < @_cache.length )
      throw new Error "µ44292 index out of bounds, got #{rpr idx}"
    return @_cache[ idx ]

  #---------------------------------------------------------------------------------------------------------
  add_tunnel: ( tunnel_factory ) ->
    validate.tunneltext_tunnel_factory             tunnel_factory
    validate.tunneltext_tunnel          ( tunnel = tunnel_factory @ )
    @tunnels.push tunnel

#-----------------------------------------------------------------------------------------------------------
### TAINT either abolish tunnel letter (`B` in this case) or pass it in as argument ###
@tunnels =
  'backslash': ( tnl ) ->
    { cloaked } = tnl
    if cloaked.length < 2 then    start_chr = stop_chr    = cloaked[ 0 ]
    else                        [ start_chr,  stop_chr, ] = cloaked
    base = 10
    ### `oc`: 'original character' ###
    _oc_backslash      = '\\'
    ### `op`: 'original pattern' ###
    _oce_backslash     = esc_re _oc_backslash
    _mcp_backslash     = ///
      #{esc_re _oc_backslash}
      ( . ) ///gu
    _tsp_backslash     = /// #{esc_re start_chr} B ( [ 0-9 a-z ]+ ) #{esc_re stop_chr} ///gu
    ### `rm`: 'remove' ###
    _rm_backslash      = /// #{esc_re _oc_backslash} ( . ) ///gu
    #---------------------------------------------------------------------------------------------------------
    hide = ( text ) =>
      R = text
      R = R.replace _mcp_backslash, ( _, $1 ) ->
        cid_txt = ( $1.codePointAt 0 ).toString base
        return "#{start_chr}B#{cid_txt}#{stop_chr}"
      return R
    #.........................................................................................................
    reveal = ( text ) =>
      R = text
      R = R.replace _tsp_backslash, ( _, $1 ) ->
        chr = String.fromCodePoint parseInt $1, base
        return "#{_oc_backslash}#{chr}"
      return R
    #.........................................................................................................
    remove = ( text ) =>
      return text.replace _rm_backslash, '$1'
    #---------------------------------------------------------------------------------------------------------
    return { name: 'backslash', hide, reveal, remove, }

  #-----------------------------------------------------------------------------------------------------------
  htmlish: ( tnl ) ->
    { cloaked } = tnl
    if cloaked.length < 2 then    start_chr = stop_chr    = cloaked[ 0 ]
    else                        [ start_chr,  stop_chr, ] = cloaked
    hide_tag_pattern    = /// ( < [^>]*? > ) ///gu
    reveal_tag_pattern  = /// #{esc_re start_chr} T ( [ 0-9 ]+ ) #{esc_re stop_chr} ///gu
    #---------------------------------------------------------------------------------------------------------
    hide = ( text ) =>
      R = text
      R = R.replace hide_tag_pattern, ( _, $1 ) =>
        cache_idx = tnl.store $1
        return "#{start_chr}T#{cache_idx}#{stop_chr}"
      return R
    #.........................................................................................................
    reveal = ( text ) =>
      return text.replace reveal_tag_pattern, ( _, $1 ) => tnl.retrieve parseInt $1, 10
    #---------------------------------------------------------------------------------------------------------
    return { name: 'backslash', hide, reveal, }


