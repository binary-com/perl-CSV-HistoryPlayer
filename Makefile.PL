use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'CSV::HistoryPlayer',
    AUTHOR           => q{binary.com <perl@binary.com>},
    VERSION_FROM     => 'lib/CSV/HistoryPlayer.pm',
    ABSTRACT         => 'Plays scattered CSV files with historic data',
    LICENSE          => 'artistic_2',
    MIN_PERL_VERSION => '5.8.0',
    clean            => {FILES => 'CSV-HistoryPlayer-*'},
    (
        eval { ExtUtils::MakeMaker->VERSION(6.64) }
        ? (
            CONFIGURE_REQUIRES => {
                "ExtUtils::MakeMaker" => "6.64",
            },
            PREREQ_PM => {
                "List::MoreUtils" => 0,
                "Moo"             => 0,
                "Path::Tiny"      => 0,
                "Text::CSV"       => 0,
            },
            TEST_REQUIRES => {
                "Test::More"     => 0,
                "Test::Warnings" => 0,
            },
            META_MERGE => {
                'meta-spec' => {version => 2},
                resources   => {
                    repository => {
                        type => 'git',
                        url  => 'https://github.com/binary-com/perl-CSV-HistoryPlayer.git',
                        web  => 'https://github.com/binary-com/perl-CSV-HistoryPlayer',
                    },
                }})
        : (
            PREREQ_PM => {
                "ExtUtils::MakeMaker" => '6.64',
                "List::MoreUtils"     => 0,
                "Moo"                 => 0,
                "Path::Tiny"          => 0,
                "Text::CSV"           => 0,
                "Test::More"          => 0,
                "Test::Warnings"      => 0,
            },
        )
    ),
);
