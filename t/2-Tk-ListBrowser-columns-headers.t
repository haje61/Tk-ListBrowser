use strict;
use warnings;
use Test::More tests => 40;
use Test::Tk;
require Tk::Photo;
require Tk::LabFrame;
require Tk::ListBrowser;
#use Tk::DynaMouseWheelBind;
use Tk::PNG;


createapp;
my @images;
if (opendir( my $dh, 't/icons')) {
	while (my $file = readdir($dh)) {
		next if $file eq '.';
		next if $file eq '..';
		push @images, $file;
	}
	closedir $dh
} else {
	warn 'cannot open icons folder'
}
@images = sort @images;

my $ib;
my $sc;
if (defined $app) {
#	$app->DynaMouseWheelBind('Tk::ListBrowser::LBCanvas');

	$ib = $app->ListBrowser(
		-arrange => 'list',
		-textanchor => 'w',
		-textside => 'right',
		-textjustify => 'left',
		-selectmode => 'multiple',
		-browsecmd => sub {
			print "browsecmd ";
			for (@_) { print  "$_ " }
			print "\n";
		},
		-command => sub {
			print "command ";
			for (@_) { print  "$_ " }
			print "\n";
		},
	)->pack(-expand =>1, -fill => 'both');
	$sc = $ib->columnCreate('test');

	$app->geometry('500x400+200+200');
}

testaccessors($sc, qw/background cellImageWidth cellTextWidth cellWidth foreground header itemtype/);

push @tests, (
	[ sub {
		$ib->columnRemove('test');
		return defined $ib
	}, 1, 'ListBrowser widget created' ],
	[ sub {
		for (@images) {
			my $text = $_;
			$ib->add($_,
				-data => "DATA$text",
				-text => $text,
				-image => $ib->Photo(
					-file => "t/icons/$_",
					-format => 'png',
				),
			);
		}
		$ib->refresh;
		my @l = $ib->infoList;
		my $size = @l;
		return $size
	}, 12, 'refresh' ],
	[ sub {
		my @l = $ib->columnList;
		return \@l 
	}, [], 'columnList' ],
	[ sub {
		$ib->columnCreate('pipodol');
		my @l = $ib->columnList;
		return \@l 
	}, ['pipodol'], 'columnCreate' ],
	[ sub {
		$ib->columnCreate('number', -before => 'pipodol');
		my @l = $ib->columnList;
		return \@l 
	}, ['number', 'pipodol'], 'columnCreate' ],
	[ sub {
		$ib->columnCreate('string', -after => 'number');
		my @l = $ib->columnList;
		return \@l 
	}, ['number', 'string', 'pipodol'], 'columnCreate' ],
	[ sub {
		return $ib->columnExists('pipodol');
	}, 1, 'columnExists true' ],
	[ sub {
		return $ib->columnExists('qjqpepk');
	}, '', 'columnExists false' ],
	[ sub {
		my $col = $ib->columnGet('pipodol');
		return $col->name
	}, 'pipodol', 'columnGet' ],
	[ sub {
		$ib->columnConfigure('pipodol', '-background', 'green');
		my $col = $ib->columnGet('pipodol');
		return $col->background
	}, 'green', 'columnConfigure' ],
	[ sub {
		return $ib->columnCget('pipodol', '-background');
	}, 'green', 'columnExists false' ],
	[ sub {
		return $ib->columnIndex('pipodol');
	}, 2, 'columnIndex' ],
	[ sub {
		$ib->columnRemove('pipodol');
		return 	$ib->columnExists('pipodol')
	}, '', 'columnRemove pipodol' ],
	[ sub {
		$ib->columnRemove('string');
		return 	$ib->columnExists('string')
	}, '', 'columnRemove string' ],
	[ sub {
		return $ib->itemExists('edit-cut.png', 'number');
	}, '', 'itemExists false' ],
	[ sub {
		$ib->columnCreate('rebmun');
		$ib->columnCreate('bernum');
		my $count = 0;
		for (@images) {
			$ib->itemCreate($_, 'number', -text => "aaaaaaaaaa$count");
			$ib->itemCreate($_, 'rebmun', -text => "dddddd$count");
			$ib->itemCreate($_, 'bernum', -text => "gggggggggggggg$count");
			$count ++
		}
		return 1
	}, 1, 'itemCreate' ],
	[ sub {
		return $ib->itemExists('edit-cut.png', 'number');
	}, 1, 'itemExists true' ],
	[ sub {
		my $i = $ib->itemGet('edit-cut.png', 'number');
		return $i->text;
	}, 'aaaaaaaaaa7', 'itemGet' ],
	[ sub {
		$ib->itemConfigure('edit-cut.png', 'number', '-background' => 'green');
		return $ib->itemGet('edit-cut.png', 'number')->background
	}, 'green', 'itemConfigure' ],
	[ sub {
		return $ib->itemCget('edit-cut.png', 'number', '-background')
	}, 'green', 'itemCget' ],
	[ sub {
		$ib->itemRemove('edit-cut.png', 'number');
		return $ib->itemExists('edit-cut.png', 'number');
	}, '', 'itemRemove' ],
	[ sub {
		$ib->headerCreate('');
		return defined $ib->headerGet('');
	}, 1, 'headerCreate headerGet main' ],
	[ sub {
		return $ib->headerExists('');
	}, 1, 'headerExists main' ],
	[ sub {
		$ib->headerCreate('number');
		return defined $ib->headerGet('number');
	}, 1, 'headerCreate headerGet column' ],
	[ sub {
		return $ib->headerExists('number');
	}, 1, 'headerExists column' ],
	[ sub {
		return $ib->headerExists('bernum');
	}, '', 'headerExists false' ],
	[ sub {
		$ib->headerConfigure('', '-text', 'pocahontas');
		return $ib->headerCget('', '-text');
	}, 'pocahontas', 'headerConfigure headerCget main' ],
	[ sub {
		$ib->headerConfigure('number', '-text', 'xena');
		return $ib->headerCget('number', '-text');
	}, 'xena', 'headerConfigure headerCget column' ],
	[ sub {
		$ib->headerRemove('');
		return $ib->headerExists('');
	}, '', 'headerRemove main' ],
	[ sub {
		$ib->headerRemove('number');
		return $ib->headerExists('number');
	}, '', 'headerRemove column' ],
	[ sub {
#		$ib->Subwidget('Canvas')->Label(-text => 'Try this!')->pack(-fill => 'x');
		$ib->headerCreate('',
			-text => 'Primary',
		);
		$ib->headerCreate('number',
			-text => 'Sec',
		);
		$ib->headerCreate('rebmun',
			-text => 'Thrd',
		);
		$ib->headerCreate('bernum',
			-text => 'Frth',
		);
		$ib->refresh;
		return '';
	}, '', 'refresh' ],
);

starttesting;

