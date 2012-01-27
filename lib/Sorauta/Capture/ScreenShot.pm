#============================================
# PC�̃f�X�N�g�b�v�摜���L���v�`�����A����I�ɑ��M����v���O���� for Mac
# -------------------------------------------
# �A�N�Z�T
# os                    String          �g�pOS
#                                               Mac or Win(not supported yet)
# capture_file_path     String          �L���v�`���摜�̃p�X
#                                               �K�{
# interval_time         Integer         �o�b�`�̎��s����
#                                               0�̏ꍇ�͈�x�̂ݎ��s
# api_url               String          �L���v�`���摜���M��API��URL
#                                               ���ꂪ�w�肳��Ă���ꍇ�̓L���v�`�����Ƀf�[�^�𑗐M����
# api_attr              HashRef         �摜���M����attribute��t����ꍇ
#                                               { id => 1, name => 2 }
# debug                 Integer         �f�o�b�O���[�h
#                                               0 ... ���O�\�����Ȃ�(�f�t�H���g)
#                                               1 ... ���O�\������
#============================================
package Sorauta::Capture::ScreenShot;
use base qw/Class::Accessor::Fast/;

use 5.012003;
use strict;
use warnings;
use utf8;
use CGI::Carp qw/fatalsToBrowser/;
use Data::Dumper;
use LWP::UserAgent;
use HTTP::Request::Common qw/POST/;
use File::Basename;
use Sorauta::Utility;

our $VERSION = '0.01';

__PACKAGE__->mk_accessors(
  qw/os capture_file_path debug interval_time api_url api_attr/);

#==========================================
# �摜�̃L���v�`�������s
# req:
# res:
#==========================================
sub execute {
  my $self = shift;

  # must be defined accessors
  if (!$self->os || !$self->capture_file_path || !length($self->interval_time)) {
    my $message = join $/,
      '====================',
      'must be define accessor ',
      'os ... Mac or Win',
      'capture_file_path ... /Users/user1/Desktop/capture.jpg',
      'interval_time ... 10(when you capture only once, please set 0)',
      '====================';
    die $message;
  }

  # execute
  print '=================================', $/;
  print ' Batch Start', $/;
  print '=================================', $/;

  while (1) {
    my $res = $self->execute_by_interval;

    print "[", get_timestamp(time), "]capture ", $res ? "succeeded" : "failed";

    if ($self->interval_time != 0) {
      print ", please wait ", $self->interval_time, "sec", $/;

      sleep $self->interval_time;
    }
    else {
      print $/;

      last;
    }
  }

  return 1;
}

#==========================================
# ����o�b�`���s
# req:
# res:
#   result: ������1�A����ȊO0
#==========================================
sub execute_by_interval {
  my $self = shift;

  # �L���v�`���摜�̃p�X�̃f�B���N�g�����A�E�g�ȏꍇ
  my($filename, $dir, $ext) = fileparse( $self->capture_file_path);
  unless (-d $dir) {
    die "was not exists directory of output capture file path";
  }

  # �L���v�`�����s
  if ($self->os =~ /^Win/i) {
    # not implement now...
  }
  else {
    my $cmd = 'screencapture -x '.$self->capture_file_path;
    `$cmd`;
  }

  # send capture data to server
  if (length($self->api_url)) {
    my $ua = new LWP::UserAgent;
    my $req = POST(
      $self->api_url,
      Content_Type => 'form-data',
      Content      => [
        %{$self->api_attr},
      ]
    );

    my $res = $ua->request($req);
    if ($res->is_success) {
      print "[Sorauta::Capture::ScreenShot]send capture file ... success.", $/;
    }
    else {
      print "[Sorauta::Capture::ScreenShot]send capture file ... failed: ", $res->status_line, $/;

      return 0;
    }
  }

  return 1;
}

1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Sorauta::Cache::HTTP::Request::Image - create cache image when you got http request.

=head1 SYNOPSIS

  use Sorauta::Capture::ScreenShot;

  my $OS = "Mac"; # or Win(but not implement now)
  my $CAPTURE_FILE_PATH = "/Users/yuki/Desktop/capture.jpg";
  my $INTERVAL_TIME = 0; # if you want to interval, set this var over 0
  my $DEBUG = 0;
  my $API_URL = "http://api_url/path/to";
  my $API_ATTRS = {
    file_name     => [$CAPTURE_FILE_PATH],
    test          => 'fugapiyo',
  };

  # capture test
  {
    Sorauta::Capture::ScreenShot->new({
        os                    => $OS,
        capture_file_path     => $CAPTURE_FILE_PATH,
        interval_time         => $INTERVAL_TIME,
        debug                 => $DEBUG,
    })->execute;
  }

  # capture and send api test
  {
    Sorauta::Capture::ScreenShot->new({
        os                    => $OS,
        capture_file_path     => $CAPTURE_FILE_PATH,
        interval_time         => $INTERVAL_TIME,
        debug                 => $DEBUG,
        api_url               => $API_URL,
        api_attr              => $API_ATTRS,
     })->execute;
  }

=head1 DESCRIPTION

create cache image when you got http request.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Yuki ANAI, E<lt>yuki@apple.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Yuki ANAI

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
