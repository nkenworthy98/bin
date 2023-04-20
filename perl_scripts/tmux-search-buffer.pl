#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions HelpMessage);
use Term::ANSIColor qw(colored);

my $tmp_file = '/tmp/tmux-search-buffer.txt';
my $tmux_active_regex = qr{^(\d+):.*?\(active\)};

GetOptions(
    'help|h' => sub { HelpMessage(0) },
    'prompt|p' => sub {
        my $lines_ref = prompt_and_filter_lines($tmp_file);
        print "$_\n" for @{$lines_ref};
        exit;
    },
) or HelpMessage(1);

# my @windows_list = `tmux list-windows`;
# chomp(@windows_list);
# my $active_window;
# foreach my $window_line (@windows_list) {
#     if ($window_line =~ $tmux_active_regex) {
#         $active_window = parse_number_at_line_start($window_line);
#         last;
#     }
# }

# my @panes_list = `tmux list-panes -t $active_window`;
# chomp(@panes_list);
# my $active_pane;
# foreach my $pane_line (@panes_list) {
#     if ($pane_line =~ $tmux_active_regex) {
#         $active_pane = parse_number_at_line_start($pane_line);
#         last;
#     }
# }

# my $window_and_pane = "$active_window.$active_pane";
# system("tmux capture-pane -t $window_and_pane -S - -J -p > $tmp_file");
system("tmux capture-pane -S - -J -p > $tmp_file");
system("tmux new-window -n search");
system("tmux send-keys 'tmux-search-buffer.pl --prompt' Enter\;");

sub parse_number_at_line_start {
    my ($line) = @_;

    if ($line =~ /^(\d+):/) {
        return $1;
    }
    else {
        die "Unable to parse number at line start: $!";
    }
}

sub prompt_and_filter_lines {
    my ($file) = @_;

    print STDERR "Search?\n";
    my $regex = <STDIN>;
    chomp($regex);

    my @matching_lines;
    open (my $fh, '<', $file)
        or die "Error when opening $file: $!";

    while (my $line = <$fh>) {
        # next if $line =~ /[\[\]]/;
        chomp($line);
        if ($line =~ /($regex)/i) {
            my $colored_regex = colored($1, "bold red");
            # print "regex: '$regex'\n";
            # print "match: '$1'\n";
            # print "color: $colored_regex\n";
            # exit;
            # my $colored_line = $line =~ s/$1/$colored_regex/gr;
            # my $colored_line = $line =~ s/\Q$1\E/$colored_regex/gr;
            my $colored_line = $line =~ s/\Q$1\E/$colored_regex/gr;
            push(@matching_lines, $colored_line);
        }
    }

    close($fh)
        or die "Error when closing $file: $!";

    return \@matching_lines;
}
