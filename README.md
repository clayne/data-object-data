# NAME

Data::Object::Data

# ABSTRACT

Podish Parser for Perl 5

# SYNOPSIS

    package main;

    use Data::Object::Data;

    my $data = Data::Object::Data->new(
      file => 't/Data_Object_Data.t'
    );

# DESCRIPTION

This package provides methods for parsing and extracting pod-like sections from
any file or package. The pod-like syntax allows for using these sections
anywhere in the source code and having Perl properly ignoring them.

# SCENARIOS

This package supports the following scenarios:

## syntax

    # POD

    # =head1 NAME
    #
    # Example #1
    #
    # =cut
    #
    # =head1 NAME
    #
    # Example #2
    #
    # =cut

    # Podish Syntax

    # =name
    #
    # Example #1
    #
    # =cut
    #
    # =name
    #
    # Example #2
    #
    # =cut

    # Podish Syntax (Nested)

    # =name
    #
    # Example #1
    #
    # +=head1 WHY?
    #
    # blah blah blah
    #
    # +=cut
    #
    # More information on the same topic as was previously mentioned in the
    # previous section demonstrating the topic as-is obvious from said section
    # ...
    #
    # =cut

    # Alternate Podish Syntax

    # @=name
    #
    # Example #1
    #
    # @=cut
    #
    # @=name
    #
    # Example #2
    #
    # @=cut

    my $data = Data::Object::Data->new(
      file => 't/examples/alternate.pod'
    );

    $data->contents('name');

    # [['Example #1'], ['Example #2']]

This package supports parsing standard POD and pod-like sections from any file
or package, anywhere in the document. Additionally, this package supports an
alternative POD definition syntax which helps differentiate between the
traditional POD usage and other usages.

# ATTRIBUTES

This package has the following attributes:

## data

    data(Str)

This attribute is read-only, accepts `(Str)` values, and is optional.

## file

    file(Str)

This attribute is read-only, accepts `(Str)` values, and is optional.

## from

    from(Str)

This attribute is read-only, accepts `(Str)` values, and is optional.

# METHODS

This package implements the following methods:

## content

    content(Str $name) : ArrayRef[Str]

The content method the pod-like section where the name matches the given
string.

- content example #1

        # =name
        #
        # Example #1
        #
        # =cut
        #
        # =name
        #
        # Example #2
        #
        # =cut

        my $data = Data::Object::Data->new(
          file => 't/examples/content.pod'
        );

        $data->content('name');

        # ['Example #1']

- content example #2

        # =name
        #
        # Example #1
        #
        # +=head1 WHY?
        #
        # blah blah blah
        #
        # +=cut
        #
        # More information on the same topic as was previously mentioned in the
        # previous section demonstrating the topic as-is obvious from said section
        # ...
        #
        # =cut

        my $data = Data::Object::Data->new(
          file => 't/examples/nested.pod'
        );

        $data->content('name');

        # ['Example #1', '', '=head1 WHY?', ...]

## contents

    contents(Str $list, Str $name) : ArrayRef[ArrayRef]

The contents method returns all pod-like sections that start with the given
string, e.g. `pod` matches `=pod foo`. This method returns an arrayref of
data for the matched sections. Optionally, you can filter the results by name
by providing an additional argument.

- contents example #1

         # =name example-1
         #
         # Example #1
         #
         # =cut
         #
         # =name example-2
         #
         # Example #2
         #
         # =cut

         my $data = Data::Object::Data->new(
           file => 't/examples/contents.pod'
         );

         $data->contents('name');

        # [['Example #1'], ['Example #2']]

- contents example #2

        # =name example-1
        #
        # Example #1
        #
        # +=head1 WHY?
        #
        # blah blah blah
        #
        # +=cut
        #
        # ...
        #
        # =cut

        my $data = Data::Object::Data->new(
          string => join "\n\n", (
            '=name example-1',
            '',
            'Example #1',
            '',
            '+=head1 WHY?',
            '',
            'blah blah blah',
            '',
            '+=cut',
            '',
            'More information on the same topic as was previously mentioned in the',
            '',
            'previous section demonstrating the topic as-is obvious from said section',
            '',
            '...',
            '',
            '=cut'
          )
        );

        $data->contents('name');

        # [['Example #1', '', '=head1 WHY?', ...]]

## item

    item(Str $name) : HashRef

The item method returns metadata for the pod-like section that matches the
given string.

- item example #1

        # =name
        #
        # Example #1
        #
        # =cut
        #
        # =name
        #
        # Example #2
        #
        # =cut

        my $data = Data::Object::Data->new(
          file => 't/examples/content.pod'
        );

        $data->item('name');

        # {
        #   index => 1,
        #   data => ['Example #1'],
        #   list => undef,
        #   name => 'name'
        # }

## list

    list(Str $name) : ArrayRef

The list method returns metadata for each pod-like section that matches the
given string.

- list example #1

        # =name example-1
        #
        # Example #1
        #
        # =cut
        #
        # =name example-2
        #
        # Example #2
        #
        # =cut

        my $data = Data::Object::Data->new(
          file => 't/examples/contents.pod'
        );

        $data->list('name');

        # [{
        #   index => 1,
        #   data => ['Example #1'],
        #   list => 'name',
        #   name => 'example-1'
        # },
        # {
        #   index => 2,
        #   data => ['Example #2'],
        #   list => 'name',
        #   name => 'example-2'
        # }]

## list\_item

    list_item(Str $list, Str $item) : ArrayRef[HashRef]

The list\_item method returns metadata for the pod-like sections that matches
the given list name and argument.

- list\_item example #1

        # =name example-1
        #
        # Example #1
        #
        # =cut
        #
        # =name example-2
        #
        # Example #2
        #
        # =cut

        my $data = Data::Object::Data->new(
          file => 't/examples/contents.pod'
        );

        $data->list_item('name', 'example-2');

        # [{
        #   index => 2,
        #   data => ['Example #2'],
        #   list => 'name',
        #   name => 'example-2'
        # }]

## parser

    parser(Str $string) : ArrayRef

The parser method extracts pod-like sections from a given string and returns an
arrayref of metadata.

- parser example #1

        # given: synopsis

        $data->parser("=pod\n\nContent\n\n=cut");

        # [{
        #   index => 1,
        #   data => ['Content'],
        #   list => undef,
        #   name => 'pod'
        # }]

## pluck

    pluck(Str $type, Str $item) : ArrayRef[HashRef]

The pluck method splices and returns metadata for the pod-like section that
matches the given list or item by name. Splicing means that the parsed dataset
will be reduced each time this method returns data, making this useful with
iterators and reducers.

- pluck example #1

        # =name example-1
        #
        # Example #1
        #
        # =cut
        #
        # =name example-2
        #
        # Example #2
        #
        # =cut

        my $data = Data::Object::Data->new(
          file => 't/examples/contents.pod'
        );

        $data->pluck('list', 'name');

        # [{
        #   index => 1,
        #   data => ['Example #1'],
        #   list => 'name',
        #   name => 'example-1'
        # },{
        #   index => 2,
        #   data => ['Example #2'],
        #   list => 'name',
        #   name => 'example-2'
        # }]

- pluck example #2

        # =name example-1
        #
        # Example #1
        #
        # =cut
        #
        # =name example-2
        #
        # Example #2
        #
        # =cut

        my $data = Data::Object::Data->new(
          file => 't/examples/contents.pod'
        );

        $data->pluck('item', 'example-1');

        # [{
        #   index => 1,
        #   data => ['Example #1'],
        #   list => 'name',
        #   name => 'example-1'
        # }]

        $data->pluck('item', 'example-2');

        # [{
        #   index => 2,
        #   data => ['Example #2'],
        #   list => 'name',
        #   name => 'example-2'
        # }]

- pluck example #3

        # =name example-1
        #
        # Example #1
        #
        # =cut
        #
        # =name example-2
        #
        # Example #2
        #
        # =cut

        my $data = Data::Object::Data->new(
          file => 't/examples/contents.pod'
        );

        $data->pluck('list', 'name');

        # [{
        #   index => 1,
        #   data => ['Example #1'],
        #   list => 'name',
        #   name => 'example-1'
        # },{
        #   index => 2,
        #   data => ['Example #2'],
        #   list => 'name',
        #   name => 'example-2'
        # }]

        $data->pluck('list', 'name');

        # []

# AUTHOR

Al Newkirk, `awncorp@cpan.org`

# LICENSE

Copyright (C) 2011-2019, Al Newkirk, et al.

This is free software; you can redistribute it and/or modify it under the terms
of the The Apache License, Version 2.0, as elucidated in the ["license
file"](https://github.com/iamalnewkirk/data-object-data/blob/master/LICENSE).

# PROJECT

[Wiki](https://github.com/iamalnewkirk/data-object-data/wiki)

[Project](https://github.com/iamalnewkirk/data-object-data)

[Initiatives](https://github.com/iamalnewkirk/data-object-data/projects)

[Milestones](https://github.com/iamalnewkirk/data-object-data/milestones)

[Contributing](https://github.com/iamalnewkirk/data-object-data/blob/master/CONTRIBUTE.md)

[Issues](https://github.com/iamalnewkirk/data-object-data/issues)
