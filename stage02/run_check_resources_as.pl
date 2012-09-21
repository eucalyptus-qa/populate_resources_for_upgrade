#!/usr/bin/perl
use strict;
use Cwd;

require "./lib_for_euare.pl";

$ENV{'EUCALYPTUS'} = "/opt/eucalyptus";


################################################## DOWNLOAD USER CREDENTIALS . PL #########################################################


###
### check for arguments
###

my $given_account_name = "";
my $given_user_name = "";


if ( @ARGV > 0 ){
	$given_account_name = shift @ARGV;
};

if ( @ARGV > 0 ){
	$given_user_name = shift @ARGV;
};


###
### read the input list
###

print "\n";
print "########################### READ INPUT FILE  ##############################\n";

read_input_file();

my $clc_ip = $ENV{'QA_CLC_IP'};
my $source_lst = $ENV{'QA_SOURCE'};

if( $clc_ip eq "" ){
	print "[ERROR]\tCouldn't find CLC's IP !\n";
	exit(1);
};

if( $source_lst eq "PACKAGE" || $source_lst eq "REPO" ){
        $ENV{'EUCALYPTUS'} = "";
};



###
### check for TEST_ACCOUNT_NAME in MEMO
###

print "\n";
print "########################### GET ACCOUNT AND USER NAME  ##############################\n";

my $account_name = "default-qa-account";
my $user_name = "default-qa-user";

if( $given_account_name ne "" ){
	$account_name = $given_account_name;
}elsif( is_test_account_name_from_memo() ){
	$account_name = $ENV{'QA_MEMO_TEST_ACCOUNT_NAME'};
};

if( $given_user_name ne "" ){
	$user_name = $given_user_name;
}elsif( is_test_account_user_name_from_memo() ){
	$user_name = $ENV{'QA_MEMO_TEST_ACCOUNT_USER_NAME'};
};

print "\n";
print "TEST ACCOUNT NAME [$account_name]\n";
print "TEST USER NAME [$user_name]\n";
print "\n";



###
### git clone populate_resources_as_user
###

print "\n";
print "########################### GIT CLONE CHECK_RESOURCES_AS_USER ##############################\n";

print "\n";
print "git clone git+ssh://test-server\@git.eucalyptus-systems.com/mnt/repos/qa/testunit/check_resources_as_user";
system("git clone git+ssh://test-server\@git.eucalyptus-systems.com/mnt/repos/qa/testunit/check_resources_as_user");

print "\n";
print "########################### ADJUST CHECK_RESOURCES_AS_USER ##############################\n";

my $from = "account00";
my $to = $account_name;
my $file = "./check_resources_as_user/check_resources_as_user.conf";

my_sed($from, $to, $file);

system("cat $file | grep $account_name");

print "\n";

$from = "user00";
$to = $user_name;

my_sed($from, $to, $file);

system("cat $file | grep $user_name");

print "\n";

print "\n";
print "########################### RUN CHECK_RESOURCES_AS_USER ##############################\n";

my $cmd = "cp ../input/2b_tested.lst ./check_resources_as_user/input/.";
system($cmd);

$cmd = "cd ./check_resources_as_user; ./run_test.pl check_resources_as_user.conf";
system($cmd);

###
### End of Script
###

print "\n";
print "[TEST_REPORT]\tCHECK_RESOURCES_AS HAS BEEN COMPLETED\n";
print "\n";

exit(0);

1;



# To make 'sed' command human-readable
# my_sed( target_text, new_text, filename);
#   --->
#        sed --in-place 's/ <target_text> / <new_text> /' <filename>
sub my_sed{

        my ($from, $to, $file) = @_;

        $from =~ s/([\'\"\/])/\\$1/g;
        $to =~ s/([\'\"\/])/\\$1/g;

        my $cmd = "sed --in-place 's/" . $from . "/" . $to . "/' " . $file;

        system($cmd);

        return 0;
}




