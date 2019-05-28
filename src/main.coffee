


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
    return R

  #---------------------------------------------------------------------------------------------------------
  reveal: ( text ) ->
    R = text
    for idx in [ 0 .. @delta ] by +1
      R = R.replace @target_seq_patterns[ idx ], @chrs[ idx ]
    return R




