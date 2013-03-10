package WebService::Wrapper;
our $VERSION = '0.01';

use Modern::Perl;
use LWP::UserAgent;
use URI::WithBase;
use WebService::Wrapper::Serializer;

use Data::Dumper;

=head1 NAME

WebService::Wrapper

=head1 SYNOPSIS

    package WebService::MyService;
    use parent "WebService::Wrapper";

    sub url { "http://api.example.com/" };
    sub methods { ... };

    package main;
    my $api = WebService::MyService->new;
    $api->...

=cut

sub url {''}
sub methods {}

sub new {
    my ($class, %params) = @_;
    bless {
        params  => \%params,
        ua      => LWP::UserAgent->new,
    }, $class
}

sub _get {
    my ($self, $path, $params) = @_;
    my $uri = URI::WithBase->new($path, $self->url);
    $uri->query_form(%$params, %{$$self{params}});
    my $result = $$self{ua}->get($uri->abs);
    $result->is_success ? WebService::Wrapper::Serializer->load_results($result) : ()
}

sub _method {
    my ($self, $name) = @_;
    my %methods = $self->methods;
    die "Error: Method '$name' does not exist in ".ref($self).".\n"
            unless exists $methods{$name};
    sub {
        my (%user_params) = @_;
        my ($path, $params) = @{$methods{$name}};
        $self->_get($path, { map {
            (ref($$params{$_}) ne 'ARRAY') ? (
                $_ => $$params{$_}
            ) : do { # TODO: Add a filter mechanism for after validating
                my ($label, $validator, $default) = @{$$params{$_}};
                (exists $user_params{$label}) ? (
                    ($user_params{$label} ~~ $validator)
                        ? ($_ => $user_params{$label}) : ()
                ) : ( defined($default) ? ($_ => $default) : () )
            }
        } keys %$params })
    }
}

our $AUTOLOAD;
sub AUTOLOAD {
    my ($self) = @_;
    my $name = $AUTOLOAD =~ s/.*://r;
    $self->_method($name)->(@_)
}


1
