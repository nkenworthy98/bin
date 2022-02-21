#!/usr/bin/perl
# hacky chatterino channel script
#
# Open chatterino with twitch channels currently running through streamlink
use strict;
use warnings;
use Getopt::Long qw(GetOptions HelpMessage);

# Set this to either 'vertical' or 'horizontal' depending on what you prefer
my $split_type = 'vertical';

GetOptions(
  'vertical|v' => sub { $split_type = 'vertical' },
  'horizontal|z' => sub { $split_type = 'horizontal' },
  'help|h' => sub { HelpMessage(0) },
) or HelpMessage(1);

my @ps_output = `ps -x`;
my @channels = ();

# Parse ps output to get the channels that are currently playing through
# streamlink
foreach my $process (@ps_output) {
  if ($process =~ /streamlink.*?twitch\.tv\/(?<channel>\w+)\Z/) {
    push(@channels, $+{channel});
  }
}

system("killall chatterino");

unless (@channels) {
  die "No channels currently playing through streamlink";
}

my $window_layout_json_path = "$ENV{HOME}/.local/share/chatterino/Settings/window-layout.json";
my $channels_data_json = get_data_json_for_channels(\@channels);
my $new_layout_json = <<"END_LAYOUT_JSON";
{
    "windows": [
        {
            "emotePopup": {
                "x": 250,
                "y": 116
            },
            "height": 723,
            "tabs": [
                {
                    "highlightsEnabled": true,
                    "selected": true,
                    "splits2": {
                        "flexh": 1,
                        "flexv": 1,
                        "items": [
$channels_data_json
                        ],
                        "type": "$split_type"
                    }
                }
            ],
            "type": "main",
            "width": 1354,
            "x": 6,
            "y": 39
        }
    ]
}
END_LAYOUT_JSON

write_contents_to_window_layout_json($window_layout_json_path, $new_layout_json);
exec("chatterino");

sub get_data_json_for_channels {
  my ($channels_ref) = @_;

  my $default_data_json = <<'END_DATA_JSON';
  {
      "data": {
          "name": "new_channel",
          "type": "twitch"
      },
      "filters": [
      ],
      "flexh": 1,
      "flexv": 1,
      "moderationMode": false,
      "type": "split"
  },
END_DATA_JSON

  my $data_json_combined = '';

  # Append another data section for each channel in the array reference to the
  # $data_json_combined variable
  foreach my $channel (@{$channels_ref}) {
    my $tmp_json = $default_data_json;
    $tmp_json =~ s/new_channel/$channel/;
    $data_json_combined .= $tmp_json;
  }

  # Last comma can cause an issue, so substitute out
  $data_json_combined =~ s/,\Z//;

  return $data_json_combined;
}

sub write_contents_to_window_layout_json {
  my ($window_layout_json, $new_file_contents) = @_;

  open(my $fh, ">", $window_layout_json)
      or die "Couldn't open $window_layout_json";
  print $fh $new_file_contents;
  close($fh);
}

=head1 NAME

hccs.pl - hacky chatterino channel script

=head1 DESCRIPTION

B<hccs.pl> opens chatterino with twitch channels currently running through streamlink.

The "hacky" part of the name comes from how the channels are opened in chatterino.
As of the time of writing this, chatterino doesn't support opening multiple channels using the split view via command line options.
In order to accomplish this without needing to learn how to edit chatterino's source code, I came up with a hacky solution.
First, when B<hccs.pl> is run, all chatterino instances are closed.
Next, B<hccs.pl> will get the names of currently running twitch channels through streamlink, and
write to chatterino's window-layout.json.
Finally, B<hccs.pl> will open chatterino using the new window-layout.json.
If multiple channels are running thorugh streamlink, it's possible to choose whether to open them using either vertical or horizontal splits.

=head1 SYNOPSIS

hccs.pl [OPTIONS]...

  -v, --vertical        Open channels with vertical splits (default)
  -z, --horizontal      Open channels with horizontal splits
  -h, --help            Print this help and exit

For more detailed documentation, run C<perldoc hccs.pl>

=cut
