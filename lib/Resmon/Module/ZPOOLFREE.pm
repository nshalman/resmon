package Resmon::Module::ZPOOLFREE;

use Resmon::Module;
use Resmon::ExtComm qw/cache_command/;

use vars qw/@ISA/;
@ISA = qw/Resmon::Module/;

# Version of the free space module that uses zpool list instead of df
# Sample config:
#
# ZPOOLFREE {
#   intmirror           : limit => 90%
#   storage1            : limit => 90%
# }

sub handler {
  my $self = shift;
  my $object = $self->{object};
  my $output = cache_command("zpool list", 120);
  my ($line) = grep(/$object\s*/, split(/\n/, $output));
  if($line =~ /(\d+)%/) {
    if($1 > $self->{'limit'}) {
      return "BAD", "$1% full";
    }
    if(exists $self->{'warnat'} && $1 > $self->{'warnat'}) {
      return "WARNING", "$1% full";
    }
    return "OK", "$1% full";
  }
  return "BAD", "0 no data";
}

1;
