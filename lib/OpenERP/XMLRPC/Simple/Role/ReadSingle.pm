package OpenERP::XMLRPC::Simple::Role::ReadSingle;
# ABSTRACT: OpenERP XML RPC wrapper for 'read' rpc method.

use Moose::Role;

requires 'read';

sub read_single
{
	my $res = shift->read( @_ );
	return unless ( defined $res && ref $res eq 'ARRAY' && scalar @$res >= 1 );
	return $res->[0];
}

1;

__END__
=pod

=head1 NAME

OpenERP::XMLRPC::Simple::Role::ReadSingle - OpenERP XML RPC wrapper for 'read' rpc method.

=head1 VERSION

version 0.001

=head1 AUTHOR

Benjamin Martin <ben@madeofpaper.co.uk>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Benjamin Martin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

