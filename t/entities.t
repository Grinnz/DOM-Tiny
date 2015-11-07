use strict;
use warnings;
use utf8;
use Test::More;
use DOM::Tiny::Entities qw(html_escape html_unescape);
use Encode 'decode';

# html_unescape
is html_unescape('&#x3c;foo&#x3E;bar&lt;baz&gt;&#x0026;&#34;'),
  "<foo>bar<baz>&\"", 'right HTML unescaped result';

# html_unescape (special entities)
is html_unescape('foo &#x2603; &CounterClockwiseContourIntegral; bar &sup1baz'),
  "foo ☃ \x{2233} bar &sup1baz", 'right HTML unescaped result';

# html_unescape (multi-character entity)
is html_unescape(decode 'UTF-8', '&acE;'), "\x{223e}\x{0333}",
  'right HTML unescaped result';

# html_unescape (apos)
is html_unescape('foobar&apos;&lt;baz&gt;&#x26;&#34;'), "foobar'<baz>&\"",
  'right HTML unescaped result';

# html_unescape (nothing to unescape)
is html_unescape('foobar'), 'foobar', 'right HTML unescaped result';

# html_unescape (UTF-8)
is html_unescape(decode 'UTF-8', 'foo&lt;baz&gt;&#x26;&#34;&OElig;&Foo;'),
  "foo<baz>&\"\x{152}&Foo;", 'right HTML unescaped result';

# html_escape
is html_escape(qq{la<f>\nbar"baz"'yada\n'&lt;la}),
  "la&lt;f&gt;\nbar&quot;baz&quot;&#39;yada\n&#39;&amp;lt;la",
  'right HTML escaped result';

# html_escape (UTF-8 with nothing to escape)
is html_escape('привет'), 'привет', 'right HTML escaped result';

# html_escape (UTF-8)
is html_escape('привет<foo>'), 'привет&lt;foo&gt;',
  'right HTML escaped result';

done_testing;
