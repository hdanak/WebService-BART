package WebService::Wrapper::Serializer::YAML {
    use YAML qw/Load Dump/;
    sub name    { 'yaml' }
    sub check   { shift ~~ /yaml/i }
    sub load    { Load(shift) }
    sub dump    { Dump(shift) }
    1
};
