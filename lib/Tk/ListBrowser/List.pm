package Tk::ListBrowser::List;

=head1 NAME

Tk::ListBrowser - Tk::ListBrowser::List - List organizer for Tk::ListBrowser.

=head1 SYNOPSIS

 require Tk::ListBrowser;
 my $ib= $window->ListBrowser(@options,
    -arrange => 'list'
 )->pack;
 $ib->add('item_1', -image => $image1, -text => $text1);
 $ib->add('item_2', -image => $image2, -text => $text2);
 $ib->refresh;

=head1 DESCRIPTION

Contains all the drawing routines for L<Tk::ListBrowser> to
draw and navigate the list in a list organized manner.

No user serviceable parts inside.

=cut

use strict;
use warnings;
use vars qw ($VERSION);
$VERSION =  0.04;

use base qw(Tk::ListBrowser::Row);

sub new {
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	return $self
}

sub draw {
	my ($self, $item, $x, $y, $column, $row) = @_;
	$self->SUPER::draw($item, $x, $y, $column, $row);
	my $entry = $item->name;
	my $cx;
	my $last;
	my @columns = $self->columnList;
	for (@columns) {
		my $col = $self->columnGet($_);
		if (defined $cx) {
			$cx = $cx + $last->cellWidth + 1;
		} else {
			$cx = $self->cellWidth + 1;
		}
		$last = $col;
		my $i = $self->itemGet($entry, $_);
		if (defined $i) {
			$i->draw($cx, $y, $column, $row, $col->cget('-itemtype'))
		}
	}
}

sub drawHeaders {
	my $self = shift;

	unless ($self->headerAvailable) {
		$self->startXY(0, 0);
		return
	}
	my @columns = $self->columnList;

	my $hheight = $self->cget('-headerheight');
	$self->startXY(0, $hheight);

	my $hf = $self->Subwidget('HeaderFrame');
	$hf->configure(-height => $hheight);
	$hf->pack('-fill', 'x');
	$self->headerPos(0);
	$self->headerPlace;
}

sub maxXY {
	my $self = shift;

	my $maxx = $self->cellWidth + 1;
	my @columns = $self->columnList;
	for (@columns) {
		my $c = $self->columnGet($_);
		$maxx = $maxx + $c->cellWidth + 1;
	}

	my $pool = $self->pool;
	my $rows = 0;
	for (@$pool) {
		$rows ++ unless $_->hidden
	}
	my $maxy = $rows * ($self->cellHeight + 1);

	return ($maxx, $maxy);
}

sub nextPosition {
	my ($self, $x, $y, $column, $row) = @_;
	my $cellheight = $self->cellHeight;
	$y = $y + $cellheight + 1;
	$row ++;
	return ($x, $y, $column, $row)
}

sub refresh {
	my $self = shift;

	#calculate sizes of side columns
	my @columns = $self->columnList;
	for (@columns) {
		$self->columnGet($_)->cellSize;
	}

	$self->SUPER::refresh;
}

sub scroll {
	return 'vertical'
}

sub startXY {
	my $self = shift;
	$self->{STARTXY} = [@_] if @_;
	my $sxy = $self->{STARTXY};
	return @$sxy
}

sub type {
	return 'list'
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

=item L<Tk::ListBrowser>

=item L<Tk::ListBrowser::Bar>

=item L<Tk::ListBrowser::Column>

=item L<Tk::ListBrowser::Item>

=item L<Tk::ListBrowser::Row>

=back

=cut

1;
