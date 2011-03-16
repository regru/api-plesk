
package API::Plesk::Response;

use strict;
use warnings;

=head1 NAME

API::Plesk::Response -  Class for processing server answers with errors handling.

=head1 SYNOPSIS

 use API::Plesk::Response;
 my $res = API::Plesk::Response->new($server_answer, @errors_list);
 # $server_answer -- data from server
 # @errors_list -- list of errors

=head1 DESCRIPTION

This class is intended for convenient processing results of work of methods of class API::Plesk.

=head1 METHODS

=over 3

=item new($server_answer, @errors))

Create server response object.

API::Plesk::Response->new($server_answer, @errors)
$server_answer - server answer,
@errors - list of errors.

=cut

# Create server response object
# STATIC, INSTANCE
sub new {
    my ( $class, %attrs) = @_;
    $class = ref $class || $class;

    my $operator  = $attrs{operator};
    my $operation = $attrs{operation};
    my @results;
    my $is_success = 1;
    
    if ( $attrs{error} ) {
        @results = ({
            errcode => '',
            errtext => $attrs{error},
            status  => 'error'
        });
        $is_success = '';
    }
    else {
        for my $dataset ( @{$attrs{response}->{$operator}} ) {
            my $result = $dataset->{$operation}->{result};
            $is_success = '' if $result->{status} eq 'error';
            push @results, $result;
        }
    }
    
    my $self = {
        result     => \@results,
        operator   => $operator,
        operation  => $operation,
        is_success => $is_success,
    };

    return bless $self, $class;
}

=item id

Get executed operation ID

Return $self->get_data->[0]->{id}, if no errors and server answer consists of only one block.

=cut

# Get executed operation ID
# INSTANCE
sub id {
    my ( $self ) = @_;
    return $self->is_success && @{$self->{result}} == 1 ? 
        $self->result->{id} : '';
}

sub guid {
    my ( $self ) = @_;
    return $self->is_success && @{$self->{result}} == 1 ? 
        $self->result->{guid} : '';
}


=item is_success

Get operation result

Return true if server answer not blank and no errors in answer.

=cut

# Return true if no errors in response
# INSTANCE
sub is_success { $_[0]->{is_success} }

=item get_data

Get data from response

Return answer response if $instance->is_success is true.

=cut

# Get data from response
# INSTANCE
sub data {
    my ( $self, $no ) = @_;
    return $self->is_success ? $self->{result}->[$no || 0]->{data} : undef;
}

sub result { 
    my ( $self ) = @_;
    return undef unless $self->is_success;
    return @{$self->{result}} == 1 ? $self->{result}->[0] : $self->{result};
}

=item error_codes

Get all error codes from response

=cut

# Get all error codes from message as arref
# INSTANCE
sub error_codes {
    my ( $self ) = @_;

    my @codes = map { ($_->{errcode}) || () } @{$self->{result}};

    return wantarray ? @codes : join ", ", @codes;
}

=item get_error_string

Return joined by ', ' error codes.

=back

=cut
sub error_texts {
    my ( $self ) = @_;

    my @texts = map { ($_->{errtext}) || () } @{$self->{result}};

    return wantarray ? @texts : join ", ", @texts;
}

sub errors {
    my ( $self ) = @_;

    my @errors = map { 
        $_->{errcode} || $_->{errtext} ? 
            ("$_->{errcode}: $_->{errtext}") :
            () 
        } @{$self->{result}};

    return wantarray ? @errors : join ", ", @errors;
}

1;

__END__

=head1 EXAMPLES

  use API::Plesk::Response;

  # API::Plesk::Response->new ('server answer', @errors_list)

  # Good answers

  my $res1 = API::Plesk::Response->new('server answer', '');
  print 'All ok' if $res1->is_success;
  # print "All ok"

  print $res1->get_data;
  # print "server answer"

  print $res1->get_error_string;
  # Print '', # because no errors


  # One error present

  my $res2 = API::Plesk::Response->new('', 'error1');
  print 'Operation failed' unless $res2->is_success; 
  # print "Operation Failed"

  print $res2->get_data;
  # print ''

  print $res2->get_error_string;
  # Print '', # print "error1"

  # Multiple errors

  my $res3 = API::Plesk::Response->new('', 'error1', 'error2', 'error3');
  print $res3->get_error_string; # print "error1, error2, error3"

=head1 EXPORT

None by default.

=head1 SEE ALSO

Blank.

=head1 AUTHOR

Odintsov Pavel E<lt>nrg[at]cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by NRG

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
