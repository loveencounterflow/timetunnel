

![](https://github.com/loveencounterflow/timetunnel/blob/master/artwork/timetunnel-logo.png?raw=true)


# TimeTunnel

TimeTunnel is a helper module for text processing tasks where certain portions of a given text should be
hidden from the view of some text processing functions.

For example, let's assume you wanted to parse some Markdown text and you already have a parsing function,
`html = P.parse text`. Let's assume that parser works quite OK but it has two flaws: it does not recognize
backslashed-escaped constructs, so it renders `foo \*bar\* baz` as `foo \<em>bar</em>\ baz` where you
expected the asterisks not to trigger a markup and get `foo *bar* baz` instead. Second, the parser does not
recognize tags with arbitrary names and standalone tags like `<xy/>`; moreover, it tries to be helpful and
normalizes unclosed tags and so on, all of which interferes with your idea of how the thing should work.

This is where TimeTunnel comes in: it applies a simple, configurable text transformation to your text which
hides 'offending' content; in this case, a simple regular expression will suffice to find and conceal
everything that looks like an HTML tag (basically, `/<[^>]*>/`). You can then process the text with the
parser of your choice, and, that being done, reveal the hidden content.

In essence, the added value of TimeTunnel is that you can prepare strings in such a way that certain text
processing tasks can be simplified.

For example, in many situations you will want to look for special characters or constructs hedged by special
characters; quite often, you also want to allow escaping such active characters with a `\` backslash. But
now you have a problem, because the processing step proper has to implement backslash-escaping, making it
more complicated (also, if you don't control the code of that processing step, adding such a facility may be
not possible).

Suppose you want to find run-of-the-mill quoted string literals in a text that are indicated by surrounding
pairs of `"` (double quotes) and `'` (single quotes); also, within a literal, both `\"` and `\'` can be used
to indicate a literal quote that does not terminate the literal. For the sake of demonstration, let's assume
you can be sure the text does not contain any `[]` (brackets). What you can then do is go and replace all
occurrances of backslashed quotes with arbitrary symbols, say, `[0]` for `\"` and `[1]` for `\'` (the role
of the brackets is just to make sure no other digits are misinterpreted as cache indices). That is, a source
like

```
var x = f( "some string with \"quotes\"" );
```

can be represented as

```
var x = f( "some string with [0]quotes[0]" );
```

In that state, you can safely apply a simple-minded regex like `/"[^"]*"/` to your source to extract the
(obfuscated) string literal and then apply the inverse replacements to obtain `some string with "quotes"`.
TimeTunnel does exactly this: it allows you to define regular expressions (so-called 'tunnels') to define
what to hide and to define character sets ('guards' and an 'integer alphabet') that define how to hide such
texts, plus it makes sure upfront that any occurrances of bracketing characters (as defined by the guards)
are hidden as well so reconstituting the original can be done with confidence.



## Demo

Here is a [demo](https://github.com/loveencounterflow/timetunnel/blob/master/src/experiments/demo.coffee) to
show the hide / modify / reveal cycle you are likely to use. In this demonstrion, we want to transform a
string by multiplying all integers (stretches of digits) it contains by `12` (for whatever reason). At the
same time, we want to keep all numbers in the text as-is when they are surrounded (escaped) by curly braces.
We choose our 'guards' (the characters that enable tunneling, see below) to be `abCD*` and our `int`eger
`alph`phabet, `intalph`, to contain the two digits `-|`. Any choice of seven characters would have done
as long as they fulfill the following properties:

* All characters must be distinct from each other, in `guards` itsel, `intalph` itself, and across `guards`
	and `intalph`.

* The default for `guards` is `\x10\x11\x12\x13\x14`, the default for `intalph` is `0123456789`, which
	results in decimal index literals during the tunneling.

* There must be exactly five guard characters.

* There must be at least two characters in the integer alphabet.

* Depending on what your text processing does with the text during tunneling, you should choose both
  parameters such that they do not interfere with processing. In the below example, we look for stretches of
  ASCII digits in the text; consequently, errors are bound to occur when using an integer alphabet
  that also uses ASCII digits, which is the reason we chose `-` and `|` as replacement digits.

Once the TimeTunnel object `tnl` is instantiated, we can add 'tunnels' to it. A tunnel is a regular
expression with or without groups that tells `tnl` what portions of text to replace with markers that are
essentially encoded and marked integers which act as indexes to a cache of string values that `tnl` builds.

You can add any number of tunnels to a TimeTunnel; these will be applied in the order they were added when
hiding, and in the reverse order when revealing. When a regular expression has groups, only the text that
was captured by the first group will be revealed; when a regex has no groups, it will be treated as if the
entire expression had been put into one group (so that will reveal the entire matched text).


```coffee
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
tnl.add_tunnel ///   \{   [0-9]+   \}   ///gu
transform tnl, original_text, "no group, equivalent to all grouped"
```

The below shows the output of the program. In each case, line `(3)` shows the result of the text processing
function, here called `modify()`. If we had not defined `intalph`, the default would have resulted in
replacements `a0b, a1b` instead of `a-b, a|b`; `a1b` would have been picked up by `modify()` and turned into
`a12b`, and then, in step `(4)` this would have resulted in an error—in this case a loud one, because

```
----------------------------
brackets not in group, removed
(1) 'abCD* A plain number 123, two bracketed ones: {123}, {124}'
(2) 'CCCDC*D* A plCCin numCDer 123, two CDrCCcketed ones: a-b, a|b'
(3) 'CCCDC*D* A plCCin numCDer 1476, two CDrCCcketed ones: a-b, a|b'
(4) 'abCD* A plain number 1476, two bracketed ones: 123, 124'
----------------------------
brackets in group, not removed
(1) 'abCD* A plain number 123, two bracketed ones: {123}, {124}'
(2) 'CCCDC*D* A plCCin numCDer 123, two CDrCCcketed ones: a-b, a|b'
(3) 'CCCDC*D* A plCCin numCDer 1476, two CDrCCcketed ones: a-b, a|b'
(4) 'abCD* A plain number 1476, two bracketed ones: {123}, {124}'
----------------------------
no group, equivalent to all grouped
(1) 'abCD* A plain number 123, two bracketed ones: {123}, {124}'
(2) 'CCCDC*D* A plCCin numCDer 123, two CDrCCcketed ones: a-b, a|b'
(3) 'CCCDC*D* A plCCin numCDer 1476, two CDrCCcketed ones: a-b, a|b'
(4) 'abCD* A plain number 1476, two bracketed ones: {123}, {124}'
```


# How Does It Even Work?

TimeTunnel instances are (explicitly or implicitly) set up with five 'guard' characters. These guards are
used to losslessly transform texts in such a way that we can be sure that they are free of certain patterns;
in particular, any text treated in this way will be free of the first two guard characters.

For example, if we pass in `abCDe` as guards, then the first two guards, `a` and `b`, will be used as start
and stop markers for text replacements that are found by tunnels; in this case, wherever a text portion is
tunneled, something like `a...b` will appear in the tunneled text

The third guard is used to escape occurrances of the start marker in the original text; in our example,
all original `a`s will be written as `CC` and all `b`s as `CD`. Since these sequences start with a `C`,
we also have to to hide all original `C`s; these will be rewritten as `Ce`, which is what the fifth
guard is for.

So when you instantiate a TimeTunnel object as `tnl = new Timetunnel 'abCDe'`, then `tnl.hide
'abcdeABCDE-CC-CD'` will give you `'CCCDcdeABCeDE-CeCe-CeD'`.

The 'hidden' text does not contain any `a`s or `b`s, and all the `C`s are supplied with a trailing `e` to
make sure that wherever the 'hidden' text contained a `CC` or a `CD`, those sequences are now broken up by
an intervening `e`. In this way, we can be sure we've cleared the way for `a` and `b` to be used as brackets
for our tunneling replacement texts.

The default value for the guards is `\x10\x11\x12\x13\x14`, which should be fine for many markup parsing
scenarios as these codepoints are not commonly used in text and should thus be just passed through by a lot
of, say, Markdown parsers. On the other hand, the next parser may choke on these characters precisely
because they are unexpected in a natural language text, which is why users may want to use a set of guards
that demonstrably works for their specific use case.

But this is just the preparation step. The interesting stuff happens when we apply all the tunnels
that have been registered with a given TimeTunnel instance.

## Applications

backslash-escaping

string literal hiding

## Presets

(WIP)

* guards
	* lower ASCII
	* ASCII
	* upper ASCII

* tunnels
	* string literals
	* HTML-ish tags
	* backslashes (to be removed)
	* backslashes (to be kept)

* integer alphabets
	* decimal
	* binary
	* hexadecimal
	* control characters
	* undefined Unicode





