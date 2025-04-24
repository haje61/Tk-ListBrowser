package Tk::ListBrowser::BaseItem;

=head1 NAME

Tk::ListBrowser::BaseItem - Base class for Item and SideColumn.

=cut

use strict;
use warnings;
use vars qw($VERSION $AUTOLOAD);
use Carp;

$VERSION =  0.04;

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=cut

sub new {
	my $class = shift;
	
	my %args = @_;

	my $canv = delete $args{'-canvas'};
	croak 'You did not specify a canvas' unless defined $canv;

	my $name = delete $args{'-name'};
	croak 'You did not specify a name' unless defined $name;

	my $self = {
		CANVAS => $canv,
		NAME => $name,
		REGION => [0, 0, 0, 0],
	};
	bless $self, $class;
	
	for (keys %args) {
		$self->configure($_, $args{$_})
	}

	return $self
}

sub AUTOLOAD {
	my $self = shift;
	return if $AUTOLOAD =~ /::DESTROY$/;
	$AUTOLOAD =~ s/^.*:://;
	return $self->{CANVAS}->$AUTOLOAD(@_);
}

sub canvas { return $_[0]->{CANVAS} }

sub cget {
	my ($self, $option) = @_;
	my $d = quotemeta('-');
	$option =~ s/^$d//;
	if ($self->can($option)) {
		return $self->$option
	} else {
		croak "Option '$option' not valid"
	}
}

sub configure {
	my ($self, $option, @values) = @_;
	my $d = quotemeta('-');
	$option =~ s/^$d//;
	if ($self->can($option)) {
		return $self->$option(@values)
	} else {
		croak "Option '$option' not valid"
	}
}

=item B<clear>I<(?$flag?)>

Clears all visible items (text, image, anchor, selection) on the canvas belonging to this item.

=cut

sub clear {
	my $self = shift;
	$self->region(0, 0, 0, 0);
}

=item B<background>I<(?$color?)>

=cut

sub background {
	my $self = shift;
	$self->{BACKGROUND} = shift if @_;
	return $self->{BACKGROUND} if defined $self->{BACKGROUND};
	return $self->canvas->cget('-background')
}

=item B<foreground>I<(?$color?)>

=cut

sub foreground {
	my $self = shift;
	$self->{FOREGROUND} = shift if @_;
	return $self->{FOREGROUND} if defined $self->{FOREGROUND};
	return $self->canvas->cget('-foreground')
}

=item B<inregion>I<($x, $y)>

Returns true if the point at I<$x>, I<$y> is inside
the region of this entry.

=cut

sub inregion {
	my ($self, $x, $y) = @_;
	my ($cx, $cy, $cdx, $cdy) = $self->region;
	return '' unless $x >= $cx;
	return '' unless $x <= $cdx;
	return '' unless $y >= $cy;
	return '' unless $y <= $cdy;
	return 1
}

=item B<itemtype>I<(?$type?)>

=cut

sub itemtype {
	my $self = shift;
	$self->{ITEMTYPE} = shift if @_;
	return $self->{ITEMTYPE}
}

=item B<name>

Returns the name of this entry.

=cut

sub name { return $_[0]->{NAME} }

sub region {
	my $self = shift;
	$self->{REGION} = [@_] if @_;
	my $r = $self->{REGION};
	return @$r;
}

=item B<textanchor>I<(?$anchor?)>

=cut

sub textanchor {
	my $self = shift;
	$self->{TEXTANCHOR} = shift if @_;
	return $self->{TEXTANCHOR} if defined $self->{TEXTANCHOR};
	return $self->canvas->cget('-textanchor')
}

=item B<textjustifyanchor>I<(?$justify?)>

=cut

sub textjustify {
	my $self = shift;
	$self->{TEXTJUSTIFY} = shift if @_;
	return $self->{TEXTJUSTIFY} if defined $self->{TEXTJUSTIFY};
	return $self->canvas->cget('-textjustify')
}

=item B<textside>I<(?$side?)>

=cut

sub textside {
	my $self = shift;
	$self->{TEXTSIDE} = shift if @_;
	return $self->{TEXTSIDE} if defined $self->{TEXTSIDE};
	return $self->canvas->cget('-textside')
}

=item B<wraplength>I<(?$size?)>

=cut

sub wraplength {
	my $self = shift;
	$self->{WRAPLENGTH} = shift if @_;
	return $self->{WRAPLENGTH} if defined $self->{WRAPLENGTH};
	return $self->canvas->cget('-wraplength')
}


=back

=head1 LICENSE

Same as Perl.

=head1 AUTHOR

Hans Jeuken (hanje at cpan dot org)

=head1 TODO

=over 4

=back

=head1 BUGS AND CAVEATS

If you find any bugs, please report them here: L<https://github.com/haje61/Tk-ListBrowser/issues>.

=head1 SEE ALSO

=over 4

=back

=cut

