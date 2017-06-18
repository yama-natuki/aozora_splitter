#!/usr/bin/perl
# last updated : 2017/06/18 14:14:40 JST
#
# 青空文庫スプリッター
# 青空文庫形式のテキストを任意サイズで分割する。デフォルトは512k
# Copyright (c) 2017 ◆.nITGbUipI
# license GPLv2
#
#

use strict;
use warnings;
use utf8;
use Encode;
use File::Basename;
use Encode::Guess qw/cp932 euc-jp 7bit-jis/; 
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);

my $splitsize = 512000;
my $ver_number = "Ver.0.01";
my ($split_size, $input_name, $show_help, $prefix_name, $print_verbose, $show_version);
my $charcode = 'utf8';

if ($^O =~ m/MSWin32/) {
  $charcode = "cp932";
}

#文字コード判定
sub guess  {
  my $file = shift;
  my $fh;
  open ($fh, '<:raw', $file) or	die "OPEN FAILED: $file, $!"; 
  my ($temp, $i);
  while ($temp .= <$fh> and ++$i < 50) { #50行読み込む
	eof and last;
  }
  close ($fh);
  return  guess_encoding($temp);
}

#コマンドラインの取得
sub getopt() {
  GetOptions(
    "size|s=s"	 => \$split_size,
    "input|i=s"	 => \$input_name,
    "help|h"	 => \$show_help,
    "prefix|p=s" => \$prefix_name,
    "verbose|v"	 => \$print_verbose,
    "version|V"	 => \$show_version
  );
}

sub help {
  print encode($charcode,
        "Usage: aozora_spliter [options] -i [INPUT_FILE] -p [PREFIX]\n".
        "\t青空文庫形式のテキストを任意サイズで分割するsplitコマンド\n".
        "\t中見出しを一つのブロックとして、指定したサイズの近似値で\n".
        "\tPREFIXの末尾に三桁の連番を付けて保存する。\n".
        "\t拡張子は[.txt]固定。\n".
        "\n".
        "\tOption:\n".
        "\t\t-s|--size\n".
        "\t\t\t分割するサイズを指定。デフォルトは512k\n".
        "\t\t\t例：-s 512k、-s 1M などと指定する。\n".
        "\t\t-i|--input\n".
        "\t\t\t分割するファイルを指定する。\n".
        "\t\t-h|--help\n".
        "\t\t\tこのテキストを表示する。\n".
        "\t\t-V|--version\n".
        "\t\t\t現在のバージョンを表示する。\n".
        "\t\t-p|--prefix\n".
        "\t\t\t分割するファイル名の接頭辞を指定する。\n".
        "\t\t\t接頭辞の後に連番が付与される。\n"
      );
  exit 0;
}

#version
sub version() {
  print encode($charcode,
        "aozora_spliter.pl ". $ver_number. " (c) 2017 ◆.nITGbUipI \n"
			  );
  exit 0;
}

sub size_convert {
  my $i =shift;
  if ($i =~ m/([0-9]+)(\D)/) {
	my $size = $1;
	my $tani = $2;
	if ($tani =~ m/k|K/) { $size = $size * 1000 }
	if ($tani =~ m/m|M/) { $size = $size * 1000 * 1000 }
	if ($tani =~ m/g|G/) { $size = $size * 1000 * 1000 * 1000 }
	return $size;
  } elsif ($i < 100000) {
	return 100000; # 最小サイズを100kに固定
  } else {
	return $i;
  }
}

sub set_enccode {
  my $i = shift;
  my $x = &guess($i);
  return $x->name;
}

sub book_split {
  my $fname = shift;
  my ($IN, $OUT);
  my $count = 1;
  my $temp;
  my $outname;
  $charcode = &set_enccode($input_name);
  open ( $IN, "<:encoding($charcode)" ,"$fname") or die "$!";
  while (my $line = <$IN>) {
	if ($line =~ m/^［＃改ページ］/) {
	  $outname = $prefix_name . sprintf("%03d", $count) . ".txt";
	  if (-f $outname) {
		print $OUT $temp;
	  }
	  else {
		open ( $OUT, ">>:encoding($charcode)" ,"$outname") or die "$!";
		print $OUT $temp;
	  }
	  $temp = "";
	  $temp = $temp . $line;
	  my $size = (-s $outname);
	  if ($size > $splitsize) {
		close( $OUT );

		$count++;
	  }
	}
	else {
	  $temp = $temp . $line;
	}
  }
  close($IN);
  close($OUT);
}

# main
{
  &getopt;

  if ($split_size) {
	$splitsize = &size_convert($split_size);
	print $splitsize . "\n";
  }

  if ($input_name) {
	if ( -f $input_name ) {
	  unless ($prefix_name) {
		my ($basename, $dirname, $ext) = fileparse($input_name, qr/\..+$/);
		$prefix_name = $basename;
		print $prefix_name . "\n";
	  }
	  &book_split($input_name);
	}
	else {
	  print encode($charcode, "ファイルが存在しません。\n");
	  exit 0;
	}
  }
  elsif ($show_help) {
    &help();
    exit 0;
  }
  elsif ($show_version) {
   &version();
   exit 0;
  }
  elsif ($print_verbose) {
  }
  else {
	&help();
	exit 0;
  }
}

