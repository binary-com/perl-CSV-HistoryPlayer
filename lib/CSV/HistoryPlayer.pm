package CSV::HistoryPlayer;

use List::MoreUtils qw(uniq);
use Moo;
use Path::Tiny;
use Text::CSV;

use strict;
use warnings;
use namespace::clean;

our $VERSION = '0.01';

has 'root_dir' => (
    is       => 'ro',
    required => 1
);

has 'dir_filter' => (
    is      => 'ro',
    default => sub {
        return sub { 1 }
    });

has 'files_mapper' => (
    is      => 'ro',
    default => sub {
        return sub {
            my $files = shift;
            return [sort { $a cmp $b } @$files];
            }
    });

has 'files' => (is => 'lazy');

has _current_data => (is => 'rw');

has '_reader' => (is => 'lazy');

sub _build_files {
    my $self = shift;

    my @files;
    my @dirs_queue = (path($self->root_dir));
    my $dir_filter = $self->dir_filter;
    while (@dirs_queue) {
        my $dir = shift(@dirs_queue);
        if ($dir_filter->($dir)) {
            for my $c ($dir->children) {
                push @dirs_queue, $c if (-d $c);
                push @files, $c
                    if ($c =~ /\.csv$/i && -s $c && -r $c && -f $c);
            }
        }
    }
    my $sorted_files = $self->files_mapper->(\@files);
    return $sorted_files;
}

sub _build__reader {
    my $self        = shift;
    my $files       = $self->files;
    my $clusters    = [uniq map { $_->basename } @$files];
    my $cluster_idx = -1;
    my @cluster_fds;
    my @cluster_csvs;
    my @cluser_files;

    my $open_cluster = sub {
        my $cluster_id = $clusters->[$cluster_idx];
        @cluser_files = grep { $_->basename eq $cluster_id } @$files;
        @cluster_fds  = ();
        @cluster_csvs = ();
        for my $cf (@cluser_files) {
            my $csv = Text::CSV->new({binary => 1})
                or die "Cannot use CSV: " . Text::CSV->error_diag();
            my $fh = $cf->filehandle("<");
            push @cluster_fds,  $fh;
            push @cluster_csvs, $csv;
        }
    };

    my @lines;
    my $read_line_from_cluster = sub {
        REDO:

        # make sure that we read last line from all cluster files
        for my $idx (0 .. @cluster_fds - 1) {
            if (!defined $lines[$idx] && !$cluster_csvs[$idx]->eof) {
                $lines[$idx] =
                    $cluster_csvs[$idx]->getline($cluster_fds[$idx]);
            }
        }

        # we assume that timestamp is the 1st column
        my @ordered_idx =
            sort { $lines[$a]->[0] <=> $lines[$b]->[0] }
            grep { defined $lines[$_] } (0 .. @lines - 1);
        if (@ordered_idx) {
            my $idx  = shift @ordered_idx;
            my $line = $lines[$idx];
            my $file = $cluser_files[$idx];
            $self->_current_data([$file, $line]);
            $lines[$idx] = undef;
        } else {
            if ($cluster_idx < @$clusters - 1) {
                $open_cluster->(++$cluster_idx);
                goto REDO;
            }
        }
    };

    return $read_line_from_cluster;
}

sub peek {
    my $self = shift;
    return $self->_current_data if $self->_current_data;
    $self->_reader->();
    return $self->_current_data;

}

sub poll {
    my $self   = shift;
    my $result = $self->_current_data;
    if (!$result) {
        $self->_reader->();
        $result = $self->_current_data;
    }
    $self->_current_data(undef);
    return $result;
}

1;
