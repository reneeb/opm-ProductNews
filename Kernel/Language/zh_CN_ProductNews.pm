# --
# Kernel/Language/zh_CN_ProductNews.pm - the Chinese translation of ProductNews
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

    # Kernel/Config/Files/ProductNews.xml
    $Lang->{'List of JS files to always be loaded for the agent interface.'} =
        '服务人员界面始终载入的JS文件列表。';
    $Lang->{'List of JS files to always be loaded for the customer interface.'} =
        '客户界面始终载入的JS文件列表。';
    $Lang->{'List of CSS files to always be loaded for the agent interface.'} =
        '服务人员界面始终载入的CSS文件列表。';
    $Lang->{'List of CSS files to always be loaded for the customer interface.'} =
        '客户界面始终载入的CSS文件列表。';
    $Lang->{'Frontend module registration for the agent interface.'} =
        '服务人员界面的前端模块注册。';
    $Lang->{'Product News'} = '';
    $Lang->{'Frontend module registration for the customer interface.'} = '';
    $Lang->{'Own Product News'} = '';
    $Lang->{'Frontend module registration for the product news administration.'} = '';
    $Lang->{'Create and manage news.'} = '创建和管理消息.';
    $Lang->{'Defines the parameters for the dashboard backend. "Group" is used to restrict access to the plugin (e. g. Group: admin;group1;group2;). "Default" indicates if the plugin is enabled by default or if the user needs to enable it manually.'} = '';
    $Lang->{'News!'} = '';
    $Lang->{'Dis-/enables displaying the teaser text of a news entry.'} = '';
    $Lang->{'Disabled'} = '';
    $Lang->{'Enabled'} = '';
    $Lang->{'Dis-/enables displaying the creator of a news entry.'} = '';
    $Lang->{'Dis-/enables edit-/delete link in dashboard for creator and users of group defined in "ProductNews::DashboardEditDeleteGroup".'} = '';
    $Lang->{'Defines the group name to which the user must belong to see edit/delete link if not creator.'} = '';
    $Lang->{'If enabled, everybody can set the message to "invalid" by clicking "mark as read".'} = '';
    $Lang->{'Configurable header for news widgets.'} = '';
    $Lang->{'Module to show product news in sidebar or Ticket zoom.'} = '';
    $Lang->{'Invalidate product news.'} = '';

    # Kernel/Modules/AdminProductNews.pm
    $Lang->{'We are sorry, you do not have permissions to edit this news item.'} =
        '抱歉, 你没有编辑该消息的权限.';

    # Kernel/Output/HTML/Templates/Standard/AdminProductNewsForm.tt
    $Lang->{'News Management'} = '消息管理';
    $Lang->{'Actions'} = '';
    $Lang->{'Go to overview'} = '';
    $Lang->{'Add/Change News'} = '增加或更改消息';
    $Lang->{'Headline'} = '标题';
    $Lang->{'A headline for the news is required.'} = '';
    $Lang->{'Teaser'} = '测试者';
    $Lang->{'Teaser is mandatory.'} = '';
    $Lang->{'Body'} = '内容';
    $Lang->{'A news text is required.'} = '';
    $Lang->{'Display'} = '';
    $Lang->{'Select a display.'} = '';
    $Lang->{'Invalidation date'} = '截止日期';
    $Lang->{'Open news when user visits dashboard'} = '当用户访问信息中心时打开该消息';
    $Lang->{'Valid'} = '有效';
    $Lang->{'Save'} = '保存';
    $Lang->{'or'} = '或';
    $Lang->{'Cancel'} = '取消';

    # Kernel/Output/HTML/Templates/Standard/ProductNewsSnippet.tt
    $Lang->{'All News'} = '所有消息';
    $Lang->{'Delete'} = '删除';
    $Lang->{'News Item'} = '新消息';
    $Lang->{'created by'} = '创建者';

    # Kernel/Output/HTML/Templates/Standard/AdminProductNewsList.tt
    $Lang->{'Add news'} = '增加消息';
    $Lang->{'List'} = '列表';
    $Lang->{'News ID'} = '消息编号';
    $Lang->{'Date'} = '日期';
    $Lang->{'Author'} = '作者';
    $Lang->{'No matches found.'} = '没有找到相匹配的.';
    $Lang->{'Delete this entry'} = '';

    # Kernel/Output/HTML/Templates/Standard/AgentProductNews.tt
    $Lang->{'Mark as read'} = '标记为已读';

    # Kernel/Output/HTML/Templates/Standard/DashboardProductNews.tt
    $Lang->{'edit'} = '编辑';
    $Lang->{'delete'} = '删除';

    # Kernel/Output/HTML/Templates/Standard/ProductNewsSnippetLogin.tt
    $Lang->{'Close this dialog'} = '关闭该对话框';

    return 1;
}

1;
