

![](https://github.com/loveencounterflow/timetunnel/blob/master/artwork/timetunnel-logo.png?raw=true)


# TimeTunnel

TimeTunnel is a helper module for text processing tasks where certain portions of a given text should be
hidden from the view of some text processing functions. For example, let's assume you wanted to parse some
Markdown text and you already have a parsing function, `html = P.parse text`.

Let's assume that parser works quite OK but it has two flaws: it does not recognize backslashed-escaped
constructs, so it renders `foo \*bar\* baz` as `foo \<em>bar</em>\ baz` where you expected the asterisks not
to trigger a markup and get `foo *bar* baz` instead.

Second, the parser does not recognize tags with arbitrary names and standalone tags like `<xy/>`; moreover,
it tries to be helpful and normalizes unclosed tags and so on, all of which interferes with your idea of how
the thing should work.

This is where TimeTunnel comes in: it applies a simple, configurable text transformation to your text which
hides 'offending' content. You can then process the text with the parser of your choice, and then reveal
the hidden content once that is done:

```coffee
#--------------------------------------------------------
# Create a TimeTunnel instance:

TIMETUNNEL      = require 'timetunnel'
tnl             = new TIMETUNNEL.Timetunnel()
tnl.add_tunnel TIMETUNNEL.tunnels.remove_backslash
tnl.add_tunnel TIMETUNNEL.tunnels.htmlish

#--------------------------------------------------------
# Hide 'offending' text,
# process it,
# finally recover tunneled parts:

tunneled_text   = tnl.hide    text
tunneled_html   = P.parse     tunneled_text
html            = tnl.reveal  tunneled_html
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





