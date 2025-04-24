package Tk::ListBrowser::LBHeader;

=head1 NAME

Tk::ListBrowser::LBHeader - Resizeable header for Tk::ListBrowser

=cut

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = 0.04;

use base qw(Tk::Derived Tk::Frame);
Construct Tk::Widget 'LBHeader';

use Tk;

my $down_arrow = '#define down_width 10
#define down_height 10
static unsigned char down_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0xff, 0x03, 0xfe, 0x01, 0xfc, 0x00, 0x78, 0x00,
   0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
';

my $empty_icon = '#define empty_width 10
#define empty_height 10
static unsigned char empty_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
';

my $up_arrow = '#define up_width 10
#define up_height 10
static unsigned char up_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x78, 0x00, 0xfc, 0x00,
   0xfe, 0x01, 0xff, 0x03, 0x00, 0x00, 0x00, 0x00 };
';


=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 ADVERTISED SUBWIDGETS

=cut


sub Populate {
	my ($self,$args) = @_;

	my $column = delete $args->{'-column'};
	die "You need to specify the -column option" unless defined $column;

	my $lb = delete $args->{'-listbrowser'};
	die "You need to specify the -listbrowser option" unless defined $lb;

	$self->SUPER::Populate($args);
	
	$self->{ACTIVE} = 0;
	$self->{COLUMN} = $column;
	$self->{LISTBROWSER} = $lb;
	
	my $label = $self->Label(
	)->pack(-side => 'left');
	$self->Advertise(Label => $label);

	my $sizer = $self->Label(
#		-anchor => 'w',
#		-justify => 'left',
		-borderwidth => 2,
	)->pack(-side => 'right', -fill => 'y');
	$self->Advertise(Sizer => $sizer);
	$sizer->bind('<Enter>', [$self, 'SizerEnter']);
	$sizer->bind('<Leave>', [$self, 'SizerLeave']);
	$sizer->bind('<Button-1>', [$self, 'SizerClick', $self, Ev('x'), Ev('y')]);
	$sizer->bind('<ButtonRelease-1>', [$self, 'SizerRelease']);
	$sizer->bind('<Motion>', [$self, 'Resize', $self, Ev('x'), Ev('y')]);
	

	my $sort = $self->Label->pack(-side => 'right');
	$self->Advertise(Sort => $sort);
	
	for ($self, $label, $sort) {
		$_->bind('<Button-3>', [$self, 'Callback', '-contextcall', Ev('x'), Ev('y')]);
		$_->bind('<Button-1>', [$self, 'SortClick']);
	}

	my $fg = $sort->cget('-foreground');
	$self->{ICONS} = {
		ascending =>  $self->Bitmap(
			-data => $up_arrow,
			-foreground => $fg,
		),
		descending =>  $self->Bitmap(
			-data => $down_arrow,
			-foreground => $fg,
		),
		none =>  $self->Bitmap(
			-data => $empty_icon,
			-foreground => $fg,
		),
	};
	$self->{SORT} = undef;
	
	$self->ConfigSpecs(
		-contextcall => ['CALLBACK', undef, undef, sub {}],
		-sortcall => ['CALLBACK', undef, undef, sub {}],
		-sortorder => ['METHOD', undef, undef, 'none'],
		-image => [$label],
		-text => [$label],
		DEFAULT => [ $self ],
	);
	return $self;
}

sub Resize {
	my ($self, $widget, $x, $y) = @_;
	if ($self->{ACTIVE}) {
		my $root = $self->rootx;
		my $dest = $root + $self->Subwidget('Sizer')->x + $self->{CLICKPOS} + $x;
		my $width = $dest - $root;
		
		my $l = $self->Subwidget('Label');
		my $s = $self->Subwidget('Sizer');
		my $r = $self->Subwidget('Sort');
		
		my $bw = $self->cget('-borderwidth');
		my $lb = $l->cget('-borderwidth');
		my $sb = $s->cget('-borderwidth');
		my $rb = $r->cget('-borderwidth');
		my $bordersize = ($bw +$lb + $sb + $rb);
		my $min = $l->width + $r->width + $s->width + $bordersize;
		unless ($width <= $min) {
			my $c = $self->{COLUMN};
			my $w = $self->{LISTBROWSER};
			$w->columnWidth($c, $width);
		}
	}
}

sub SetSort {
	my ($self, $sort) = @_;
	my $icon = $self->{ICONS}->{$sort};
	$self->Subwidget('Sort')->configure(-image => $icon);	
}

sub SizerClick {
	my ($self, $widget, $x, $y) = @_;
	$self->{CLICKPOS} = $x;
	$self->{ACTIVE} = 1;
}

sub SizerEnter {
	my $self = shift;
	my $s = $self->Subwidget('Sizer');
	$self->{CURSORSAVE} = $s->cget('-cursor');
	$s->configure(-cursor => 'sb_h_double_arrow');
}

sub SizerLeave {
	my $self = shift;
	my $s = $self->Subwidget('Sizer');
	my $c = $self->{CURSORSAVE};
	$s->configure(-cursor => $c) if defined $c;
	delete $self->{CURSORSAVE};
}

sub SizerRelease {
	my $self = shift;
	$self->{ACTIVE} = 0;
}

my %sortmatrix = (
	ascending => 'descending',
	descending => 'ascending',
	none => 'ascending',
);

sub SortClick {
	my $self = shift;
	my $name = $self->Subwidget('Label')->cget('-text');
	my $order = $sortmatrix{$self->cget('-sortorder')};
	$self->Callback('-sortcall', $name, $order);
}


sub sortorder {
	my ($self, $sort) = @_;
	if (defined $sort) {
		$self->{SORT} = $sort;
		$self->after(1, ['SetSort', $self, $sort]);
	}
	return $self->{SORT}	
}

=head1 LICENSE

Same as Perl.

=head1 AUTHOR

Hans Jeuken (hanje at cpan dot org)

=head1 BUGS AND CAVEATS

If you find any bugs, please contact the author.

=head1 SEE ALSO

=over 4

=item L<Tk::FileBrowser>

=item L<Tk::HList>

=back

=cut

1;









