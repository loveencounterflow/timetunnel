

# TunnelText

TunnelText is a helper module for text processing tasks where certain portions of a given text should be
hidden from the view of some text processing functions. For example, let's assume you wanted to parse some
Markdown text and you already have a parsing function, `html = P.parse text`.

Let's assume that parser works quite OK but it has two flaws: it does not recognize backslashed-escaped
constructs, so it renders `foo \*bar\* baz` as `foo \<em>bar</em>\ baz` where you expected the asterisks not
to trigger a markup and get `foo *bar* baz` instead.

Second, the parser does not recognize tags with arbitrary names and standalone tags like `<xy/>`; moreover,
it tries to be helpful and normalizes unclosed tags and so on, all of which interferes with your idea of how
the thing should work.

This is where TunnelText comes in: it applies a simple, configurable text transformation to your text which
hides 'offending' content. You can then process the text with the parser of your choice, and then reveal
the hidden content once that is done:

```coffee
#--------------------------------------------------------
# Create a TunnelText instance:

TUNNELTEXT      = require 'tunneltext'
tnl             = new TUNNELTEXT.Tunneltext()
tnl.add_tunnel TUNNELTEXT.tunnels.remove_backslash
tnl.add_tunnel TUNNELTEXT.tunnels.htmlish

#--------------------------------------------------------
# Hide 'offending' text,
# process it,
# finally recover tunneled parts:

tunneled_text   = tnl.hide    text
tunneled_html   = P.parse     tunneled_text
html            = tnl.reveal  tunneled_html
```



