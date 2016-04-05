# --
# Kernel/Language/de_ProductNews.pm - the german translation of ProductNews
# Copyright (C) 2011-2014 Perl-Services.de, http://perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::zh_CN_ProductNews;

use strict;
use warnings;
use utf8;

our $VERSION = 0.02;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    $Lang->{'Add news'}        = '增加消息';
    $Lang->{'News ID'}         = '消息编号';
    $Lang->{'Headline'}        = '标题';
    $Lang->{'Teaser'}          = '测试者';
    $Lang->{'Author'}          = '作者';
    $Lang->{'Add/Change News'} = '增加或更改消息';
    $Lang->{'News Management'} = '消息管理';
    $Lang->{'edit'}            = '编辑';
    $Lang->{'delete'}          = '删除';
    $Lang->{'created by'}      = '创建者';
    $Lang->{'News Item'}       = '新消息';

    $Lang->{'Create and manage news.'} = '创建和管理消息.';

    $Lang->{'All News'}        = '所有消息';
    $Lang->{"We are sorry, you do not have permissions to edit this news item."} =
        '抱歉, 你没有编辑该消息的权限.';

    $Lang->{"Invalidate date"} = '截止日期';
    $Lang->{'Open news when user visits dashboard'} = '当用户访问信息中心时打开该消息';
    $Lang->{'Mark as read'}                         = '标记为已读';

    return 1;
}

1;
