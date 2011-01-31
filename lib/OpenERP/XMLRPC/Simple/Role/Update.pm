package OpenERP::XMLRPC::Simple::Role::Update;
# ABSTRACT: OpenERP XML RPC 'wirte' method

use Moose::Role;

requires 'object_execute';

sub update
{
	my $self 	= shift;
	my $object 	= shift;
	my $ids 	= shift;
	my $args 	= shift;

    # ensure we pass an array of IDs to the RPC..
    $ids = [ $ids ] unless ( ref $ids eq 'ARRAY' );

	return $self->rpc->object_execute('write', $object, $ids, $args );
}

1;

__END__
=pod

=head1 NAME

OpenERP::XMLRPC::Simple::Role::Update - OpenERP XML RPC 'wirte' method

=head1 VERSION

version 0.001

=head1 AUTHOR

Benjamin Martin <ben@madeofpaper.co.uk>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Benjamin Martin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

