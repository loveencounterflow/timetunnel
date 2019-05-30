



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
@convert = ( src, srctable, desttable ) ->
  srclen  = srctable.length
  destlen = desttable.length
  # first convert to base 10
  val     = 0
  numlen  = src.length
  #.........................................................................................................
  for i in [ 0 ... numlen ]
    val = val * srclen + srctable.indexOf src.charAt i
  #.........................................................................................................
  if val < 0
    return 0
  #.........................................................................................................
  if ( destlen is 1 )
    return desttable[ 0 ].repeat( val )
  #.........................................................................................................
  # then covert to any base
  r   = val %% destlen
  R   = desttable.charAt(r)
  q   = val // destlen
  while q isnt 0
    r   = q %% destlen
    q   = q // destlen
    R = ( desttable.charAt r ) + R
  #.........................................................................................................
  return R


@encode_integer = ( n, alphabet ) ->
  validate.nonnegative_integer n
  validate.timetunnel_integercodec_alphabet alphabet

