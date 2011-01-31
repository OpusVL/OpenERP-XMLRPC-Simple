package OpenERP::XMLRPC::Simple::Role::Search;
# ABSTRACT: OpenERP XML RPC 'search' method

use Moose::Role;

requires 'object_execute';

sub search
{
	my $self 	= shift;
	my $object 	= shift;
	my $args 	= shift;
	return $self->rpc->object_execute('search', $object, $args );
}

1;

__END__
=pod

=head1 NAME

OpenERP::XMLRPC::Simple::Role::Search - OpenERP XML RPC 'search' method

=head1 VERSION

version 0.001

=head1 AUTHOR

Benjamin Martin <ben@madeofpaper.co.uk>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Benjamin Martin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

