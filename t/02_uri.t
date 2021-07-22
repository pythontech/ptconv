# $Id: 02_uri.t,v 1.4 2014/06/20 13:23:21 pythontech Exp $
use strict;
use Test::More tests => 5;

use PythonTech::Conv qw(uq uqs uqp uqf ux);

is(uq('abc+!"$%41^&*()[]{},.<>/?;:#~'),
   'abc%2B!%22$%2541%5E%26*()%5B%5D%7B%7D,.%3C%3E%2F%3F%3B%3A%23~',
   'uri quoting');
is(ux('abc%2B%21%22%24%2541%5E%26%2A%28%29%3C%3E%2F%3F'),
   'abc+!"$%41^&*()<>/?',
   'uri expanding');
is(uqp('~/My Files/#mum&dad#'),
   '~/My%20Files/%23mum&dad%23',
   'uri path quoting');
is(uqs('What the?!@/'),
   'What%20the%3F!@%2F',
   'uri segment quoting');
is(uqf('X-&/;?#="'),
   'X-&/;?%23=%22',
   'uri fragment quoting');
