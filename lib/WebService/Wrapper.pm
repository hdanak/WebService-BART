package WebService::Wrapper;
our $VERSION = '0.01';

use Modern::Perl;
use LWP::UserAgent;
use URI::WithBase;
use WebService::Wrapper::Serializer;

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

sub _create_method {
    my ($self, $specs) = @_;
    sub {
        my ($self, %extra_params) = @_;
        my ($path, $params) = @$specs;
        $self->_get($path, { (map {
            ref($$params{$_}) ? () : ($_ => $$params{$_})
        } keys %$params), %extra_params })
    }
}

our $AUTOLOAD;
sub AUTOLOAD {
    my ($self) = @_;
    my $name = $AUTOLOAD =~ s/.*://r;
    my %methods = $self->methods;
    no strict 'refs';
    if (exists $methods{$name}) {
        $self->_create_method($methods{$name})->(@_);
    } else {
        die "Error: Method '$name' does not exist in ".ref($self).".\n"
    }
}


1
