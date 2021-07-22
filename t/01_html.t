# $Id: 01_html.t,v 1.1 2005/12/19 12:43:24 pythontech Exp $
use strict;
use Test::More tests => 2;

use PythonTech::Conv qw(hq hx);

is(hq('<foo&bar>"baz'." isn't"), '&lt;foo&amp;bar&gt;&quot;baz isn\'t',
   'html quoting');
is(hx('&lt;lt;&gt;lt;&amp;amp;&quot;'), '<lt;>lt;&amp;"', 'html expanding');
