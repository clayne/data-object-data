package Data::Object::Data;

use 5.014;

use strict;
use warnings;
use routines;

use Moo;

require Carp;

# VERSION

# BUILD

has data => (
  is => 'ro',
  builder => 'new_data',
  lazy => 1
);

fun new_data($self) {
  my $file = $self->file;
  my $data = $self->parser($self->lines);

  return $data;
}

has file => (
  is => 'ro',
  builder => 'new_file',
  lazy => 1
);

fun new_file($self) {
  my $from = $self->from or return;
  my $path = $from =~ s/::/\//gr;

  return $INC{"$path.pm"};
}

has from => (
  is => 'ro',
  lazy => 1
);

fun BUILD($self, $args) {
  $self->file;
  $self->data;

  return $self;
}

# METHODS

method content($name) {
  my $item = $self->item($name) or return;
  my $data = $item->{data};

  return $data;
}

method contents($name, $seek) {
  my $items = $self->list($name) or return;
  @$items = grep { $_->{name} eq $seek } @$items if $seek;
  my $data = [map { $_->{data} } @$items];

  return $data;
}

method item($name) {
  for my $item (@{$self->{data}}) {
    return $item if !$item->{list} && $item->{name} eq $name;
  }

  return;
}

method lines() {
  my $file = $self->file;

  return '' if !$file || !-f $file;

  open my $fh, '<', $file or Carp::confess "$!: $file";
  my $lines = join "\n", <$fh>;
  close $fh;

  return $lines;
}

method list($name) {
  return if !$name;

  my @list;

  for my $item (@{$self->{data}}) {
    push @list, $item if $item->{list} && $item->{list} eq $name;
  }

  return [sort { $a->{index} <=> $b->{index} } @list];
}

method list_item($list, $name) {
  my $items = $self->list($list) or return;
  my $data = [grep { $_->{name} eq $name } @$items];

  return $data;
}

method parser($data) {
  $data =~ s/\n*$/\n/;

  my @chunks = split /^(?:@=|=)\s*(.+?)\s*\r?\n/m, $data;

  shift @chunks;

  my $items = [];

  while (my ($meta, $data) = splice @chunks, 0, 2) {
    next unless $meta && $data;
    next unless $meta ne 'cut';

    my @info = split /\s/, $meta, 2;
    my ($list, $name) = @info == 2 ? @info : (undef, @info);

    $data = [split /\n\n/, $data];

    my $item = { name => $name, data => $data, index => @$items + 1, list => $list };

    push @$items, $item;
  }

  return $items;
}

method pluck($type, $name) {
  return if !$name;
  return if !$type || ($type ne 'item' && $type ne 'list');

  my (@list, @copy);

  for my $item (@{$self->{data}}) {
    my $matched = 0;

    $matched = 1 if $type eq 'list' && $item->{list} && $item->{list} eq $name;
    $matched = 1 if $type eq 'item' && $item->{name} && $item->{name} eq $name;

    push @list, $item if $matched;
    push @copy, $item if !$matched;
  }

  $self->{data} = [sort { $a->{index} <=> $b->{index} } @copy];

  return $type eq 'name' ? $list[0] : [@list];
}

1;
