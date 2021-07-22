# $Id: 03_xml.t,v 1.1 2006/05/18 10:45:26 pythontech Exp $
use strict;
use Test::More tests => 2;

use PythonTech::Conv qw(xq xx);

is(xq('<foo&bar>"baz'." isn't"), '&lt;foo&amp;bar&gt;&quot;baz isn&apos;t',
   'xml quoting');
is(xx('&lt;lt;&gt;lt;&amp;amp;&quot;&apos;'), '<lt;>lt;&amp;"\'', 'xml expanding');
