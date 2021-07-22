#=======================================================================
#	$Id: Conv.pm,v 1.7 2014/06/20 13:23:05 pythontech Exp $
#	Conversions to (un)escape text
#	Copyright (C) 2005-2007  Python Technology Limited
#
#	This program is free software; you can redistribute it and/or
#	modify it under the terms of the GNU General Public License
#	as published by the Free Software Foundation; either version 2
#	of the License, or (at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program; if not, write to the Free Software
#	Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  
#	02111-1307, USA.
#=======================================================================
package PythonTech::Conv;
use strict;
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(html_escape html_unescape
		    hq hx
		    xml_escape xml_unescape
		    xq xx
		    uri_escape uri_escape_segment uri_escape_path uri_escape_fragment
                    uri_unescape
		    uq uqs uqp uqf ux
		    c_escape c_unescape
		    cq cx);

#-----------------------------------------------------------------------
#	Escape arbitrary text for use as part of a URI.  See RFC 3986.
#	Depending on the context, various puctuation characters are
#	allowed unescaped.
#	Allowed everywhere (unreserved): - . _ ~
#	Some application meaning (sub-delims): ! $ & ' ( ) * + , ; =
#	Used in uri syntax (gen-delims): : / ? # [ ] @
#	Allowed in path segment: all except / ? # [ ]
#	Allowed in query or fragment: all except # [ ]
#	The _path variant expects the input to be a sequence of path
#	segments separated by '/' (e.g. a unix file path) and output
#	the equivalent URI path with escaped segments separated by '/'.
#-----------------------------------------------------------------------
sub uq {
    my($text) = @_;
    $text =~ s/([^-\w\.\~\!\$\'\(\)\*\,])/sprintf("%%%02X",unpack("C",$1))/eg;
    return $text;
}

sub uqs {
    my($text) = @_;
    $text =~ s/([^-\w\.\~\!\$\&\'\(\)\*\+\,\;\=\:\@])/sprintf("%%%02X",unpack("C",$1))/ego;
    return $text;
}

sub uqp {
    my($text) = @_;
    $text =~ s/([^-\w\.\~\!\$\&\'\(\)\*\+\,\;\=\:\@\/])/sprintf("%%%02X",unpack("C",$1))/ego;
    return $text;
}

sub uqf {
    my($text) = @_;
    $text =~ s/([^-\w\.\~\!\$\&\'\(\)\*\+\,\;\=\:\@\/\?])/sprintf("%%%02X",unpack("C",$1))/ego;
    return $text;
}

sub ux {
    my($text) = @_;
    $text =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack("C", hex($1))/ego;
    return $text;
}

#-----------------------------------------------------------------------
#	Excape arbitrary text so that it can be included in HTML
#-----------------------------------------------------------------------
sub hq {
    my($text) = @_;
    $text =~ s/\&/\&amp;/g;
    $text =~ s/\</\&lt;/g;
    $text =~ s/\>/\&gt;/g;
    $text =~ s/\"/\&quot;/g;
    return $text;
}

my %html_ent =
(
 amp => '&',
 lt => '<',
 gt => '>',
 quot => '"',
 );

sub hx {
    my($html) = @_;
    my $text = '';
    while (1) {
	if ($html =~ m!\G([^\&]+)!gc) {
	    $text .= $1;
	} elsif ($html =~ m!\G\&([a-z]+);!gc) {
	    my $ch = $html_ent{$1};
	    die "Unknown entity \&$1\n"
		unless defined $ch;
	    $text .= $ch;
	} elsif ($html =~ m!\G\&\#(\d+);!gc) {
	    $text .= pack("C", $1);
	} else {
	    last;
	}
    }
    die "Unrecognised html escape at ".substr($html,pos($html),10)."\n"
	unless pos($html) == length($html);
    return $text;
}

#-----------------------------------------------------------------------
#	Excape arbitrary text so that it can be included in XML
#-----------------------------------------------------------------------
sub xq {
    my($text) = @_;
    $text =~ s/\&/\&amp;/g;
    $text =~ s/\</\&lt;/g;
    $text =~ s/\>/\&gt;/g;
    $text =~ s/\"/\&quot;/g;
    $text =~ s/\'/\&apos;/g;
    return $text;
}

my %xml_ent =
(
 amp => '&',
 lt => '<',
 gt => '>',
 quot => '"',
 apos => "'",
 );

sub xx {
    my($xml) = @_;
    my $text = '';
    while (1) {
	if ($xml =~ m!\G([^\&]+)!gc) {
	    $text .= $1;
	} elsif ($xml =~ m!\G\&([a-z]+);!gc) {
	    my $ch = $xml_ent{$1};
	    die "Unknown entity \&$1\n"
		unless defined $ch;
	    $text .= $ch;
	} elsif ($xml =~ m!\G\&\#(\d+);!gc) {
	    $text .= pack("C", $1);
	} else {
	    last;
	}
    }
    die "Unrecognised xml escape at ".substr($xml,pos($xml),10)."\n"
	unless pos($xml) == length($xml);
    return $text;
}

#-----------------------------------------------------------------------
#	Escape arbitrary text with common codes compatible with C, Perl:
#	\t \n \r \\ \" \012 \xa3
#	
#-----------------------------------------------------------------------
sub cq {
    my($text) = @_;
    $text =~ s!\\!\\\\!g;
    $text =~ s!\"!\\\"!g;
    $text =~ s!\t!\\t!g;
    $text =~ s!\n!\\n!g;
    $text =~ s!\r!\\r!g;
    $text =~ s!([^\x20-\x7e])!sprintf("\\x%02x",unpack("C",$1))!eg;
    return $text;
}

my %c_ent =
(
 t => "\t",
 n => "\n",
 r => "\r",
 f => "\f",
 b => "\b",
 a => "\a",
 );

sub cx {
    my($text) = @_;
    my $res;
    while (1) {
	if ($text =~ m!\G([^\\]+)!gc) {
	    $res .= $1;
	} elsif ($text =~ m!\G\\([tnrfba])!gc) {
	    $res .= $c_ent{$1};
	} elsif ($text =~ m!\G\\x([0-9a-f]{2})!gci) {
	    $res .= pack("C", hex($1));
	} elsif ($text =~ m!\G\\([0-7]{1,3})!gc) {
	    $res .= pack("C", oct($1));
	} elsif ($text =~ m!\G\\([\\\"])!gc) {
	    $res .= $1;
	} else {
	    last;
	}
    }
    die "Unrecognised c escape at ".substr($text,pos($text),10)."\n"
	unless pos($text) == length($text);
    return $res;
}

#-----------------------------------------------------------------------
#	Long-winded aliases
#-----------------------------------------------------------------------
sub html_escape {hq(@_)}
sub html_unescape {hx(@_)}
sub xml_escape {xq(@_)}
sub xml_unescape {xx(@_)}
sub uri_escape {uq(@_)}
sub uri_escape_segment {uqs(@_)}
sub uri_escape_path {uqp(@_)}
sub uri_escape_fragment {uqf(@_)}
sub uri_unescape {ux(@_)}
sub c_escape {cq(@_)}
sub c_unescape {cx(@_)}

1;
