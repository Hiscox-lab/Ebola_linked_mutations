#!/usr/bin/perl -w
@samples=("Kidney","Liver","Lung","Spleen");
foreach $smaple(@samples) {
open (DATA, "$smaple\_control_all.csv");
open (DATAU, ">$smaple\_control_up.csv");
open (DATAD, ">$smaple\_control_down.csv");
while (<DATA>) {
    chomp;
    @cols=split(/\,/);
    $avg=($cols[1]+$cols[2]+$cols[3]+$cols[4])/4;
    if (/^\,/) {
        print DATAD "$_\,average\n";
        print DATAU "$_\,average\n";
    }elsif ($avg < -1 && $cols[8] < 0.05) {
        print DATAD "$_\,$avg\n";
        push(@alldown,"$cols[0]\,$smaple\n");
    }elsif ($avg > 1 && $cols[8] < 0.05) {
        print DATAU "$_\,$avg\n";
        push(@allup,"$cols[0]\,$smaple\n");
    }
}
close DATA;
close DATAU;
close DATAD;
}
open (DATAUI, ">all_control_up_id.csv");
open (DATADI, ">all_control_down_id.csv");
print DATADI @alldown;
print DATAUI @allup;
