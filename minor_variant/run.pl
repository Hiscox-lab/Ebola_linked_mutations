#!/usr/bin/perl

$list="sample name";
$outputpath="path to output";

###mapping

mkdir "$outputpath/alignment";

system("bowtie2 --local -X 2000 --no-mixed -x reference_genome.fa -p $thread -1 fq1.fa -2 fq2.fa -S $outputpath/alignment/$list\.sam 2> $outputpath/alignment/$list\_mapping_rate");
system ("samtools view -@ $thread -q 10 -F 2316 -Sb $outputpath/alignment/$list\.sam | samtools sort -@ $thread -o $outputpath/alignment/$list\.sorted.bam");

unlink ("$outputpath/alignment/$list\.sam");
system("samtools index $outputpath/alignment/$list\.sorted.bam");
system("java -jar ./Scripts/picard.jar MarkDuplicates INPUT=$outputpath/alignment/$list\.sorted.bam OUTPUT=$outputpath/alignment/$list\_markup.bam METRICS_FILE=dup.txt VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=true TMP_DIR=tmp ASSUME_SORTED=true");
system("samtools index $outputpath/alignment/$list\_markup.bam");
unlink ("$outputpath/alignment/$list\.sorted.bam");
unlink ("$outputpath/alignment/$list\.sorted.bam.bai");

###running diversiutils, filtration, minor variation
mkdir "$outputpath/1_Syn_NonSyn_aa";
mkdir "$outputpath/2_Syn_NonSyn_filter";
mkdir "$outputpath/3_Syn_NonSyn_filter_aa";
system ("perl ./Scripts/diversiutils_modified_v2.pl -bam $outputpath/alignment/$list\_markup.bam -ref reference_genome.fa -orfs CodingRegion.txt -stub $outputpath/1_Syn_NonSyn_aa/$list");
system ("perl ./Scripts/diversifilter_v2.pl -in $outputpath/1_Syn_NonSyn_aa/$list -pQ 0.05 -pS 100000 -stub $outputpath/2_Syn_NonSyn_filter/$list");
system ("perl ./Scripts/Syn_NonSyn_filter_aa_new.pl $outputpath/1_Syn_NonSyn_aa/$list\_entropy.txt $options{'codingRegion'} $outputpath/2_Syn_NonSyn_filter/$list\_filter.txt $outputpath/1_Syn_NonSyn_aa/$list\_AA_all_condon.txt $outputpath/1_Syn_NonSyn_aa/$list\_AA_all_AA.txt $outputpath/3_Syn_NonSyn_filter_aa/$list\_AA_all_condon_filtered.txt $outputpath/3_Syn_NonSyn_filter_aa/$list\_AA_all_AA_filtered.txt $outputpath/3_Syn_NonSyn_filter_aa/$list\_minor_change_filtered.txt");

