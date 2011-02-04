
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Simple interaction with OpenERP XML RPC interface.',
  'AUTHOR' => 'Benjamin Martin <ben@madeofpaper.co.uk>',
  'BUILD_REQUIRES' => {},
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'OpenERP-XMLRPC-Simple',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'OpenERP::XMLRPC::Simple',
  'PREREQ_PM' => {
    'File::ShareDir' => '1.02',
    'File::Slurp' => '9999.13',
    'Moose' => '1.15',
    'MooseX::Role::XMLRPC::Client' => '0.04',
    'Net::HTTPServer' => '1.1.1',
    'XML::Simple' => '2.18'
  },
  'VERSION_FROM' => 'lib/OpenERP/XMLRPC/Client.pm',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



