package ddos;

use strict;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);

our $VERSION = 100;

sub Init {
	return 1;
}

sub run {
       	my $argref       = shift;
       	my $profile      = $$argref{'profile'};
      	my $profilegroup = $$argref{'profilegroup'};
       	my $timeslot     = $$argref{'timeslot'};

       	my $profilepath     = NfProfile::ProfilePath($profile, $profilegroup);
	my %profileinfo     = NfProfile::ReadProfile($profile, $profilegroup);
       	my $all_sources     = join ':', keys %{$profileinfo{'channel'}};
       	my $netflow_sources = "$NfConf::PROFILEDATADIR/$profilepath/$all_sources";

	system("$NfConf::PREFIX/nfdump -M $netflow_sources ....");

	my $year = substr $timeslot, 0, 4;
	my $month = substr $timeslot, 4, 2;
	my $day = substr $timeslot, 6, 2;

	my $nfdump_command = "$NfConf::PREFIX/nfdump -M $netflow_sources -r ${year}/${month}/${day}/nfcapd.${timeslot} -a -q -A srcip,dstip -T  -o \"fmt:%sa %da %opkt %ipkt\" \"flags SA\"";


	my @nfdump_output = `$nfdump_command`;

	my $total_time = 5 * 60;

	my $alarm_threshold = 2 * $total_time;
	my $warning_threshold = 1 * $total_time;

	my @alarms = ();
	my @warnings = ();
	
	my $to_send_message = 0;
	
	foreach my $a_line (@nfdump_output) {
		my @splitted_line = split("\\s+", $a_line);
		next if scalar @splitted_line != 6;
		my $source_ip = $splitted_line[1];
		my $destination_ip = $splitted_line[3];
		my $in_packets = $splitted_line[4];
		my $out_packets = $splitted_line[5];
		
		if ($in_packets >= $alarm_threshold or 
			$out_packets >= $alarm_threshold ) {
			my $alarm_text = "\nSource: $source_ip\nDestination: $destination_ip\nTimeslot: $timeslot \nIn Packets: $in_packets \nOut Packets: $out_packets";
			push (@alarms, $alarm_text);
			$to_send_message = 1;
		} elsif ( $in_packets >= $warning_threshold or 
			$out_packets >= $warning_threshold) {
			my $alarm_text = "\nSource: $source_ip\nDestination: $destination_ip\nTimeslot: $timeslot \nIn Packets: $in_packets \nOut Packets: $out_packets";
			push (@warnings, $alarm_text);
			$to_send_message = 1;
		}
	}

	if ($to_send_message) {
		my $all_alarms = join('\n', @alarms);
		my $all_warnings = join('\n', @warnings);

		my $message = "$all_alarms $all_warnings";
		my $host_name = `hostname`;
		my $message = Email::MIME->create(
		  header_str => [
		    From    => "nfsen.ddos.plugin\@$host_name",
		    To      => 'suren.k.n@me.com',
		    Subject => 'DDOS people',
		  ],
		  attributes => {
		    encoding => 'quoted-printable',
		    charset  => 'ISO-8859-1',
		  },
		  body_str => "$message",
		);
		use Email::Sender::Simple qw(sendmail);
		sendmail($message);
	}

}

sub Cleanup {
}



1;
