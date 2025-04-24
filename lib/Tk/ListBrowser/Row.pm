package Tk::ListBrowser::Row;

=head1 NAME

Tk::ListBrowser - Tk::ListBrowser::Row - Row organizer for Tk::ListBrowser.

=head1 SYNOPSIS

 require Tk::ListBrowser;
 my $ib= $window->ListBrowser(@options,
    -arrange => 'row'
 )->pack;
 $ib->add('item_1', -image => $image1, -text => $text1);
 $ib->add('item_2', -image => $image2, -text => $text2);
 $ib->refresh;

=head1 DESCRIPTION

Contains all the drawing routines for L<Tk::ListBrowser> to
draw and navigate the list in a row organized manner.

No user serviceable parts inside.

=cut

use strict;
use warnings;
use vars qw($VERSION $AUTOLOAD);
$VERSION =  0.04;
use Carp;
use Math::Round;

sub new {
	my ($class, $lb) = @_;
	carp 'You did not specify a list browser' unless defined $lb;
	
	my $self = {
		CELLHEIGHT => 0,
		CELLWIDTH => 0,
		IMAGEHEIGHT => 0,
		IMAGEWIDTH => 0,
		TEXTHEIGHT => 0,
		TEXTWIDTH => 0,
		LISTBROWSER => $lb,
	};
	bless $self, $class;
	return $self
}

sub AUTOLOAD {
	my $self = shift;
	return if $AUTOLOAD =~ /::DESTROY$/;
	$AUTOLOAD =~ s/^.*:://;
	return $self->{LISTBROWSER}->$AUTOLOAD(@_);
}

sub cellSize {
	my $self = shift;

	my $cellheight = 0;
	my $cellwidth = 0;
	my $imageheight = 0;
	my $imagewidth = 0;
	my $textheight = 0;
	my $textwidth = 0;
	my $pool = $self->pool;
	for (@$pool) {
		my $entry = $_;
		my ($iw, $ih, $tw, $th) = $entry->minCellSize($self->cget('-itemtype'));
		$imageheight = $ih if $ih > $imageheight;
		$imagewidth = $iw if $iw > $imagewidth;
		$textheight = $th if $th > $textheight;
		$textwidth = $tw if $tw > $textwidth;
		for ($self->columnList) {
			my $col = $_;
			my $type = $self->columnCget($col, '-itemtype');
			my $item = $self->itemGet($entry->name, $col);
			if (defined $item) {
				my ($iw, $ih, $tw, $th) = $entry->minCellSize($type);
				$imageheight = $ih if $ih > $imageheight;
				$textheight = $th if $th > $textheight;
			}
			
		}
	}
	my $itemtype = $self->cget('-itemtype');
	if ($itemtype eq 'image') {
		$cellheight = $imageheight;
		$cellwidth = $imagewidth;
	} elsif ($itemtype eq 'text') {
		$cellheight = $textheight;
		$cellwidth = $textwidth;
	} else {
		my $textside = $self->cget('-textside');
		if (($textside eq 'top') or ($textside eq 'bottom')) {
			$cellheight = $imageheight + $textheight;
			$cellwidth = $imagewidth;
			$cellwidth = $textwidth if $textwidth > $cellwidth;
		} elsif (($textside eq 'left') or ($textside eq 'right')) {
			$cellheight = $imageheight;
			$cellheight = $textheight if $textheight > $cellheight;
			$cellwidth = $imagewidth + $textwidth;
		}
	}
	$self->cellHeight($cellheight);
	$self->cellImageHeight($imageheight);
	$self->cellImageWidth($imagewidth);
	$self->cellTextHeight($textheight);
	$self->cellTextWidth($textwidth);
	$self->cellWidth($cellwidth);
	return ($cellwidth, $cellheight)
}

sub draw {
	my ($self, $item, $x, $y, $column, $row) = @_;
	$item->draw($x, $y, $column, $row, $self->cget('-itemtype'))
}

sub drawHeaders {
}

sub maxXY {
	my $self = shift;
	my $maxc = 0;
	my $maxr = 0;
	my $pool = $self->pool;
	for (@$pool) {
		my $c = $_->column;
		$maxc = $c if ((defined $c) and ($c > $maxc));
		my $r = $_->row;
		$maxr = $r if ((defined $r) and ($r > $maxr));
	}
	my $maxx = ($maxc + 1) * ($self->cellWidth + 1);
	my $maxy = ($maxr + 1) * ($self->cellHeight + 1);
	return ($maxx, $maxy);
}

sub nextPosition {
	my ($self, $x, $y, $column, $row) = @_;
	my $cellheight = $self->cellHeight;
	my $cellwidth = $self->cellWidth;
	my $newx = $x + ($cellwidth * 2);
	my ($cwidth, $cheight) = $self->canvasSize;
	if ($newx >= $cwidth) {
		$x = 0;
		$y = $y + $cellheight + 1;
		$column = 0;
		$row ++;
	} else {
		$x = $x + $cellwidth + 1;
		$column ++;
	}
	return ($x, $y, $column, $row)
}

sub refresh {
	my $self = shift;
	my $pool = $self->pool;
	$self->clear;
	$self->cellSize;
	$self->drawHeaders;
	my ($x, $y) = $self->startXY;
	my $ioffsetx = 0;
	my $column = 0;
	my $row = 0;
	my $fontdescent = $self->fontMetrics($self->cget('-font'), '-descent');
	for (@$pool) {
		my $item = $_;
		next if $item->hidden;
		$self->draw($item, $x, $y, $column, $row);

		($x, $y, $column, $row) = $self->nextPosition($x, $y, $column, $row);
	}
	$self->configure(-scrollregion => [0, 0, $self->maxXY]);
}

sub scroll {
	return 'vertical'
}

sub startXY {
	return (0, 0)
}

sub type {
	return 'row'
}

=head1 LICENSE

Same as Perl.

=head1 AUTHOR

Hans Jeuken (hanje at cpan dot org)

=head1 BUGS AND CAVEATS

If you find any bugs, please report them here: L<https://github.com/haje61/Tk-ListBrowser/issues>.

=head1 SEE ALSO

=over 4

=item L<Tk::ListBrowser>

=item L<Tk::ListBrowser::Bar>

=item L<Tk::ListBrowser::Column>

=item L<Tk::ListBrowser::Item>

=item L<Tk::ListBrowser::List>

=back

=cut

1;
