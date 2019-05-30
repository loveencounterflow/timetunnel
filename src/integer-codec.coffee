



"use strict"

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'TIMETUNNEL/INTEGER-CODEC'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
types                     = require './types'
{ isa
  validate
  declare
  size_of
  type_of }               = types

###

thx to https://rot47.net/base.html
convert.js
http://rot47.net
https://helloacm.com
http://codingforspeed.com
Dr Zhihua Lai

###

# BASE2  = "01"
# BASE8  = "01234567"
# BASE10 = "0123456789"
# BASE16 = "0123456789abcdef"
# BASE32 = "0123456789abcdefghijklmnopqrstuvwxyz"
# BASE62 = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
# BASE75 = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_.,!=-*(){}[]"

#-----------------------------------------------------------------------------------------------------------
validate_distinctive_nonempty_chrs = ( x ) ->
  validate.text x
  R = Array.from x
  ### TAINT implement intertype.validate() with custom test, custom message ###
  unless ( R.length > 1 )
    throw new Error "µ12009 expected a text with two or more characters, got #{rpr x}"
  unless ( new Set R ).size is R.length
    throw new Error "µ12009 expected a text with two or more distinct characters, got #{rpr x}"
  return R

#-----------------------------------------------------------------------------------------------------------
validate_is_subset = ( x, y ) ->
  unless ( x.every ( xx ) -> xx in y )
    throw new Error "µ33344 number contains illegal digits: #{rpr x}, alphabet #{rpr y}"
  return null

#-----------------------------------------------------------------------------------------------------------
@_convert = ( src, srctable, desttable ) ->
  srctable  = validate_distinctive_nonempty_chrs srctable
  desttable = validate_distinctive_nonempty_chrs desttable
  srclen    = srctable.length
  destlen   = desttable.length
  validate.nonempty_text src
  src       = Array.from src
  validate_is_subset src, srctable
  #.........................................................................................................
  # Remove leading zeros except the last one:
  src.shift() while ( src.length > 1 ) and ( src[ 0 ] is srctable[ 0 ] )
  #.........................................................................................................
  # If srctable equals desttable and leading zeros have been removed, src already contains result: ###
  return src.join '' if ( srctable is desttable )
  #.........................................................................................................
  # first convert to base 10
  val       = 0
  numlen    = src.length
  #.........................................................................................................
  for i in [ 0 ... numlen ]
    val = val * srclen + srctable.indexOf src[ i ]
  #.........................................................................................................
  if val < 0
    return 0
  #.........................................................................................................
  # then covert to any base
  r   = val %% destlen
  R   = desttable[ r ]
  q   = val // destlen
  while q isnt 0
    r   = q %% destlen
    q   = q // destlen
    R = ( desttable[ r ] ) + R
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@encode = ( n, alphabet ) ->
  validate.count n
  return @_convert "#{n}", '0123456789', alphabet

#-----------------------------------------------------------------------------------------------------------
@decode = ( text, alphabet ) ->
  return parseInt ( @_convert text, alphabet, '0123456789' ), 10



