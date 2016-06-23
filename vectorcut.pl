# Extracts sequence between V2 and V3.  Adds length after sequence and label.
use warnings;
use strict;

#Takes the first argument as the input file
my $fastafile = $ARGV[0];
open(HITLIST, $fastafile);
my @hitlist = <HITLIST>;

#Takes the second argument as the output file
my $outputfile = $ARGV[1];
open(OUTPUT, ">$outputfile");

#Make an output file without tabs and lengths
open(OUTPUT1, ">NoLength_$outputfile");

#Make an output file of sequences that don't match
open(OUTPUT2, ">Errors_$outputfile");

#Make a temporary file for fasta file that is chomped
my $temp_file = "temp.txt";
open(TEMP_FILE, ">$temp_file");

my $line = "";
my $seqcount = 0;
my $inbetween = "";
my $count = 1;
my $seqLength = 0;
my $seqName = "";
my $countFastaSeqs = 0;
my $newlineON = 0;

	foreach $line (@hitlist) {
	
		unless($line =~ /^>/){
			$line =~ s/\s+$//;
			print TEMP_FILE "$line";
		}
		else{
			if($newlineON == 0){
				print TEMP_FILE "$line";
				$newlineON = 1;
			}
			else{
				print TEMP_FILE "\n$line";
			}
		}
	}

open(TEMP_FILE, "<$temp_file");
my @temp_file = <TEMP_FILE>;
	
	foreach $line (@temp_file) {
	
		#Copy the sequence name that comes after ">"
		if ($line =~ /^>/){
			$seqName = substr($line, 0); #Don't restrict size. Start with ">"
			$seqName =~ s/\s//g; #Removes whitespaces
			$countFastaSeqs++;
		}

		else {
			($inbetween)= $line =~ /CC.?TGGCCGCGGGATT(.*)AATCACTAGTGCGGCC/g;
			
			if (defined $inbetween){
				$seqLength = length ($inbetween);
				#print OUTPUT $seqLength; #for testing
				print OUTPUT "$seqName\t";
				print OUTPUT "${inbetween}\t";
				print OUTPUT "$seqLength\n";
				print OUTPUT1 "$seqName\n";
				print OUTPUT1 "${inbetween}\n";
				$seqcount++;
				
				##Cleaning up
				$inbetween = "";
				$seqLength = 0;
				$seqName = "";
			}
			
			elsif (!defined ($inbetween)){
				($inbetween)= $line =~ /GCCGCACTAGTGATT(.*)AATCCCGCGGCCATGGCG/g;
				$seqLength = length ($inbetween);

				if ((defined ($inbetween)) && ($seqLength > 50)){
					print OUTPUT "$seqName\t";
					print OUTPUT "${inbetween}\t";
					print OUTPUT "$seqLength\n";
					print OUTPUT1 "$seqName\n";
					print OUTPUT1 "${inbetween}\n";
					$seqcount++;
				}
				
				elsif (!defined ($inbetween)){
					print OUTPUT2 $seqName . "  Check vector sequence!\n";
					print OUTPUT2 $line;  ##will print the complete sequence to figure out what's wrong for testing
				}
				
				##Garbage collection
				undef $inbetween;
				$seqLength = 0;
				$seqName = "";
			}
		}
			$inbetween = "";
		}
	
	print OUTPUT "There are " . "$seqcount" . " good sequences out of " . "$countFastaSeqs" . " total sequences.";
	print OUTPUT "\nThere are " . ($countFastaSeqs - $seqcount) . " bad sequences.";
	
close(HITLIST);
close(OUTPUT);
close(TEMP_FILE);
	
#Exit the program
exit;
