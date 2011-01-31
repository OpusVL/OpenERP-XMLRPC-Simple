package OpenERP::XMLRPC::Simple::Role::Delete;
# ABSTRACT: OpenERP XML RPC 'unlink' method

use Moose::Role;

requires 'object_execute';

sub delete
{
	my $self 	= shift;
	my $object 	= shift;
	my $ids 	= shift;

    # ensure we pass an array of IDs to the RPC..
    $ids = [ $ids ] unless ( ref $ids eq 'ARRAY' );

	return $self->rpc->object_execute('unlink', $object, $ids );
}

1;

__END__
=pod

=head1 NAME

OpenERP::XMLRPC::Simple::Role::Delete - OpenERP XML RPC 'unlink' method

=head1 VERSION

version 0.001

=head1 AUTHOR

Benjamin Martin <ben@madeofpaper.co.uk>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Benjamin Martin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

