use inc::Module::Install;
name 'Moose-Set';
all_from 'lib/Moose/Set.pm';

requires 'Moose' => 0;
requires 'Sub::Exporter' => 0;
requires 'List::MoreUtils' => 0;

build_requires 'Test::More';
use_test_base;
auto_include;
auto_install;
WriteAll;
