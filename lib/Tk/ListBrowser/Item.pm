package Tk::ListBrowser::Item;

=head1 NAME

Tk::ListBrowser::Item - List entry holding object.

=cut

use strict;
use warnings;
use vars qw ($VERSION);
use Carp;

$VERSION =  0.04;

use base qw(Tk::ListBrowser::BaseItem);

=head1 SYNOPSIS

 my $item = $listbrowser->add($entryname, @options);

 my $item = $listbrowser->get($entryname);

=head1 DESCRIPTION

This module creates an object that holds all information of every entry.
You will never need to create an item object yourself.

=head1 METHODS

=over 4

=cut

sub new {
	my $class = shift;
	
	my $self = $class->SUPER::new(@_);

	$self->hidden(0) unless defined $self->hidden;
	$self->owner($self->canvas) unless defined $self->owner;
	$self->text('') unless defined $self->text;
	$self->{ANCHOR} = 0;
	$self->{SELECTED} = 0;
	
	return $self
}

=item B<anchor>I<($flag)>

If I<$flag> is set it makes the anchor rectangle of this entry visible.
Otherwise clears it.

=cut

sub anchor {
	my ($self, $flag) = @_;
	my $c = $self->canvas;
	my $p = $c->Subwidget('Canvas');
	$flag = 1 unless defined $flag;
	my $r = $self->crect;
	$self->{ANCHOR} = $flag;
	if ($flag) {
		my $fg = $c->cget('-foreground');
		$p->itemconfigure($r,
			-outline => $fg, # TODO should not be a hard coded color.
			-dash => [3, 2],
		);
	} else {
		my $outline;
		$outline = $c->cget('-selectbackground') if $self->selected;
		$p->itemconfigure($r,
			-outline => $outline,
			-dash => undef,
		);
	}
	return $self->{ANCHOR}
}

=item B<anchored>

Returns true if the anchor is set to this entry.

=cut

sub anchored { return $_[0]->{ANCHOR} }

sub canvas { return $_[0]->{CANVAS} }

sub cimage {
	my $self = shift;
	$self->{CIMAGE} = shift if @_;
	return $self->{CIMAGE}
}

=item B<clear>I<(?$flag?)>

Clears all visible items (text, image, anchor, selection) on the canvas belonging to this item.

=cut

sub clear {
	my $self = shift;
	my $c = $self->canvas->Subwidget('Canvas');
	for ($self->cimage, $self->ctext, $self->crect) {
		$c->delete($_) if defined $_;
	}
	$self->cimage(undef);
	$self->ctext(undef);
	$self->crect(undef);
	$self->column(undef);
	$self->row(undef);
	$self->region(0, 0, 0, 0);
}

=item B<column>I<(?$column?)>

Sets and returns the column number of this entry

=cut

sub column {
	my $self = shift;
	$self->{COLUMN} = shift if @_;
	return $self->{COLUMN}
}

sub crect {
	my $self = shift;
	$self->{CRECT} = shift if @_;
	return $self->{CRECT}
}

sub ctext {
	my $self = shift;
	$self->{CTEXT} = shift if @_;
	return $self->{CTEXT}
}

=item B<data>I<(?$data?)>

Sets and returns the data scalar assigned to this entry.

=cut

sub data {
	my $self = shift;
	$self->{DATA} = shift if @_;
	return $self->{DATA}
}

sub draw {
	my ($self, $x, $y, $column, $row, $type) = @_;

	my $image = $self->image;
	my $ih = 0;
	my $iw = 0;
	if (defined $image) {
		$ih = $image->height;
		$iw = $image->width;
	}

	my $text = $self->text;
	my $th = 0;
	my $tw = 0;
	if (defined $text) {
		$text = $self->textFormat($text);
		$th = $self->textHeight($text);
		$tw = $self->textWidth($text);
	}

	my $imageoffsetx = 0;
	my $imageoffsety = 0;
	my $textoffsetx = 0;
	my $textoffsety = 0;
	my @textcavity = (0, 0, 0, 0);

	my $owner = $self->owner;
	my $cellheight = $owner->cellHeight;
	my $cellwidth = $owner->cellWidth;
	my $imageheight = $owner->cellImageHeight;
	my $imagewidth = $owner->cellImageWidth;
	my $textheight = $owner->cellTextHeight;
	my $textwidth = $owner->cellTextWidth;

	my $itemtype = $owner->cget('-itemtype');
	if ($itemtype eq 'image') {
		$imageoffsetx = int(($cellwidth - $iw)/2);
		$imageoffsety = int(($cellheight - $ih)/2);
	} elsif ($itemtype eq 'text') {
		@textcavity = (0 ,0, $cellwidth, $cellheight)
	} else {
		my $textside = $owner->cget('-textside');
		if ($textside eq 'top') {
			@textcavity = (0, 0, $cellwidth, $textheight);
			$imageoffsety = $textheight + int(($imageheight - $ih)/2);
			$imageoffsetx = $imageoffsetx + int(($cellwidth - $iw)/2);
		} elsif ($textside eq 'bottom') {
			@textcavity = (0, $imageheight, $cellwidth, $cellheight);
			$imageoffsetx = $imageoffsetx + int(($cellwidth - $iw)/2);
			$imageoffsety = $imageoffsety + int(($imageheight - $ih)/2);
		} elsif ($textside eq 'left') {
			@textcavity = (0, 0, $textwidth, $cellheight);
			$imageoffsety = $imageoffsety + int(($cellheight - $ih)/2);
			$imageoffsetx = $textwidth;
		} elsif ($textside eq 'right') {
			@textcavity = ($imagewidth, 0, $cellwidth, $cellheight);
			$imageoffsety = $imageoffsety + int(($cellheight - $ih)/2);
		}
	}

	my $centerx = $textcavity[0] + int(($textcavity[2] - $textcavity[0] - $tw)/2);
	my $centery = $textcavity[1] + int(($textcavity[3] - $textcavity[1] - $th)/2);

	my $textanchor = $owner->cget('-textanchor');
	if ($textanchor eq '') {
		$textoffsetx = $centerx;
		$textoffsety = $centery;
	} elsif ($textanchor eq 's') {
		$textoffsetx = $centerx;
		$textoffsety = $textcavity[3] - $th;
	} elsif ($textanchor eq 'e') {
		$textoffsetx = $textcavity[2] - $tw;
		$textoffsety = $centery;
	} elsif ($textanchor eq 'n') {
		$textoffsetx = $centerx;
		$textoffsety = $textcavity[1];
	} elsif ($textanchor eq 'w') {
		$textoffsetx = $textcavity[0];
		$textoffsety = $centery;
	} elsif ($textanchor eq 'se') {
		$textoffsetx = $textcavity[2] - $tw;
		$textoffsety = $textcavity[3] - $th;
	} elsif ($textanchor eq 'sw') {
		$textoffsetx = $textcavity[0];
		$textoffsety = $textcavity[3] - $th;
	} elsif ($textanchor eq 'ne') {
		$textoffsetx = $textcavity[2] - $tw;
		$textoffsety = $textcavity[1];
	} elsif ($textanchor eq 'nw') {
		$textoffsetx = $textcavity[0];
		$textoffsety = $textcavity[1];
	}

	if ($type =~ /image/) {
		my $itag;
		$itag = $self->createImage($x + $imageoffsetx, $y + $imageoffsety, 
			-image => $image, 
			-anchor => 'nw',
		) if defined $image;
		$self->cimage($itag);
	}
	if ($type =~ /text/) {
		my $ttag;
		$ttag = $self->createText($x + $textoffsetx, $y + $textoffsety, 
			-text => $text,
			-justify => $self->canvas->cget('-textjustify'),
			-anchor => 'nw',
			-font => $self->canvas->cget('-font'),
		) if defined $text;
		$self->ctext($ttag);
	}
	my $dx = $x + $cellwidth;
	my $dy = $y + $cellheight;
	my $rtag = $self->createRectangle($x, $y, $dx, $dy,
		-fill => undef,
		-outline => undef,
	);
	$self->crect($rtag);
	$self->region($x, $y, $dx, $dy);
	$self->column($column);
	$self->row($row);
}

=item B<hidden>I<(?$flag?)>

Sets and returns the hidden flag belonging to this entry.

=cut

sub hidden {
	my $self = shift;
	$self->{HIDDEN} = shift if @_;
	return $self->{HIDDEN}
}

=item B<image>I<(?$image?)>

Sets and returns the image object belonging to this entry.

=cut

sub image {
	my $self = shift;
	$self->{IMAGE} = shift if @_;
	return $self->{IMAGE}
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

sub minCellSize {
	my ($self, $itemtype) = @_;
	$itemtype = 'imagetext' unless defined $itemtype;
	my $cellheight = 0;
	my $cellwidth = 0;;
	my $imageheight = 0;
	my $imagewidth = 0;
	my $textheight = 0;
	my $textwidth = 0;
	my $image = $self->image;
	if (defined $image) {
		$imageheight = $image->height;
		$imagewidth = $image->width;
	}
	my $text = $self->text;
	if (defined $text) {
		$text = $self->textFormat($text);
		$textheight = $self->textHeight($text);
		$textwidth = $self->textWidth($text);
	}
	my $pad = 6;
	$pad = 4 if $itemtype ne 'imagetext';
	$imageheight = $imageheight + $pad;
	$imagewidth = $imagewidth + $pad;
	$textheight = $textheight + $pad;
	$textwidth = $textwidth + $pad;
	return ($imagewidth, $imageheight, $textwidth, $textheight)
}

=item B<name>

Sets and returns name of this entry.

=cut

sub name { return $_[0]->{NAME} }

=item B<owner>I<(?$owner?)>

=cut

sub owner {
	my $self = shift;
	$self->{OWNER} = shift if @_;
	return $self->{OWNER}
}


sub region {
	my $self = shift;
	$self->{REGION} = [@_] if @_;
	my $r = $self->{REGION};
	return @$r;
}

=item B<row>

Sets and returns the row number of this entry.

=cut

sub row {
	my $self = shift;
	$self->{ROW} = shift if @_;
	return $self->{ROW}
}

=item B<select>I<($flag)>

If I<$flag> is set it changes the look of this entry as selected.
Otherwise changes the look to un-selected it.

=cut

sub select {
	my ($self, $flag) = @_;
	$flag = 1 unless defined $flag;
	my $c = $self->canvas;
	my $p = $c->Subwidget('Canvas');
	my $r = $self->crect;
	my $t = $self->ctext;
	$self->{TFILL} = $p->itemcget($t, '-fill') unless defined $self->{TFILL};
	$self->{SELECTED} = $flag;
	if ($flag) {
		$p->itemconfigure($r,
			-fill => $c->cget('-selectbackground'),
			-outline => $c->cget('-selectbackground'),
		);
		$p->raise($self->cimage);
		$p->raise($t);
		$p->itemconfigure($t, 
			-fill => $c->cget('-selectforeground'),
		);
	} else {
		my $outline= $c->cget('-foreground');
		$outline = undef unless $self->anchored;
		$p->itemconfigure($r,
			-fill => undef,
			-outline => $outline,
		);
		$p->itemconfigure($t, 
			-fill => $self->{TFILL},
		);
	}
}

=item B<selected>

Returns true if this entry is belonging to the selection.

=cut

sub selected { return $_[0]->{SELECTED} }

=item B<text>I<(?$string?)>

Sets and returns the text string belonging to this entry.

=cut

sub text {
	my $self = shift;
	$self->{TEXT} = shift if @_;
	return $self->{TEXT}
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

