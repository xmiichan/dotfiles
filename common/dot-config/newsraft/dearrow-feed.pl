#!/usr/bin/env perl
#
use strict;
use warnings;
use Digest::SHA qw(sha256_hex);
use JSON::PP;

my $API = "https://sponsor.ajay.app/api/branding";
my $UA  = "newsraft-dearrow/1 (personal feed reader)";
# accept non-original titles at/above this score
my $MIN_VOTES = 0;

my $channel = shift @ARGV
    or die "usage: dearrow-feed.pl CHANNEL_ID\n";

sub fetch {
    my ($url) = @_;
    open(my $fh, "-|", "curl", "-sL", "--max-time", "20",
         "-A", $UA, $url) or return undef;
    local $/;
    my $body = <$fh>;
    close($fh);
    return $body;
}

sub xml_escape {
    my ($s) = @_;
    $s =~ s/&/&amp;/g;
    $s =~ s/</&lt;/g;
    $s =~ s/>/&gt;/g;
    return $s;
}

sub best_title {
    my ($vid) = @_;
    my $prefix = substr(sha256_hex($vid), 0, 4);
    my $body = fetch("$API/$prefix") or return undef;
    my $batch = eval { JSON::PP->new->decode($body) } or return undef;
    my $rec = $batch->{$vid} or return undef;

    my @cands = grep {
        !$_->{original} && ($_->{locked} || ($_->{votes} // 0) >= $MIN_VOTES)
    } @{ $rec->{titles} || [] };

    return undef unless @cands;

    @cands = sort {
        (($b->{locked}) ? 1 : 0) <=> (($a->{locked}) ? 1 : 0)
            || ($b->{votes} // 0) <=> ($a->{votes} // 0)
    } @cands;
    (my $title = $cands[0]{title}) =~ s/>//g;
    return $title;
}

my $feed = fetch(
    "https://www.youtube.com/feeds/videos.xml?channel_id=$channel"
) or die "feed fetch failed\n";

$feed =~ s{<entry>(.*?)</entry>}{
    my $entry = $1;
    if ($entry =~ m{<yt:videoId>([^<]+)</yt:videoId>}) {
        my $new = best_title($1);
        if (defined $new) {
            my $esc = xml_escape($new);
            $entry =~ s{<title[^>]*>.*?</title>}
                       {<title>$esc</title>}s;
        }
    }
    "<entry>$entry</entry>";
}ges;

print $feed;
