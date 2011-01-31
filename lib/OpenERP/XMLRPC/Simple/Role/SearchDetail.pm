package OpenERP::XMLRPC::Simple::Role::SearchDetail;
# ABSTRACT: Simple interaction with OpenERP XML RPC interface.

use Moose::Role;

requires 'search';
requires 'read';

sub search_detail
{
	my $self = shift;
	my $object 	= shift;
	my $args 	= shift;

	# search and get ids..
	my $ids = $self->search( $object, $args );
	return unless ( defined $ids && ref $ids eq 'ARRAY' && scalar @$ids >= 1 );

	# read data from all the ids..
	return $self->read( $object, $ids );
}

1;

__END__
=pod

=head1 NAME

OpenERP::XMLRPC::Simple::Role::SearchDetail - Simple interaction with OpenERP XML RPC interface.

=head1 VERSION

version 0.001

=head1 AUTHOR

Benjamin Martin <ben@madeofpaper.co.uk>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Benjamin Martin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

