# --
# Kernel/Language/de_ProductNews.pm - the German translation of ProductNews
# Copyright (C) 2011-2016 Perl-Services.de, http://perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_ProductNews;

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
        'Liste der JavaScript-Dateien, die immer im Agenten-Interface geladen werden sollen.';
    $Lang->{'List of JS files to always be loaded for the customer interface.'} =
        'Liste der JavaScript-Dateien, die immer im Kunden-Interface geladen werden sollen.';
    $Lang->{'List of CSS files to always be loaded for the agent interface.'} =
        'Liste der CSS-Dateien, die immer im Agenten-Interface geladen werden sollen.';
    $Lang->{'List of CSS files to always be loaded for the customer interface.'} =
        'Liste der CSS-Dateien, die immer im Kunden-Interface geladen werden sollen.';
    $Lang->{'Frontend module registration for the agent interface.'} =
        'Frontendmodul-Registration für das Agenten Interface.';
    $Lang->{'Product News'} = '';
    $Lang->{'Frontend module registration for the invoice states interface.'} = '';
    $Lang->{'Create and manage news.'} = 'Nachrichten erstellen und verwalten.';
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
    $Lang->{'Module to product news in sidebar.'} = '';
    $Lang->{'Invalidate product news.'} = '';

    # Kernel/Modules/AdminProductNews.pm
    $Lang->{'We are sorry, you do not have permissions to edit this news item.'} =
        'Sie haben keine Berechtigung diesen News-Eintrag zu bearbeiten.';

    # Kernel/Output/HTML/Templates/Standard/AdminProductNewsForm.tt
    $Lang->{'News Management'} = 'Nachrichten verwalten';
    $Lang->{'Actions'} = '';
    $Lang->{'Go to overview'} = '';
    $Lang->{'Add/Change News'} = 'Nachricht hinzufügen/ändern';
    $Lang->{'Headline'} = 'Überschrift';
    $Lang->{'A headline for the news is required.'} = '';
    $Lang->{'Teaser'} = 'Kurztext';
    $Lang->{'Teaser is mandatory.'} = '';
    $Lang->{'Body'} = '';
    $Lang->{'A news text is required.'} = '';
    $Lang->{'Display'} = '';
    $Lang->{'Select a display.'} = '';
    $Lang->{'Invalidate date'} = 'Nachricht gültig bis';
    $Lang->{'Open news when user visits dashboard'} = 'Nachricht öffnen wenn Agenten das Dashboard öffnen';
    $Lang->{'Valid'} = '';
    $Lang->{'Save'} = '';
    $Lang->{'or'} = '';
    $Lang->{'Cancel'} = '';

    # Kernel/Output/HTML/Templates/Standard/ProductNewsSnippet.tt
    $Lang->{'All News'} = 'Alle Nachrichten';
    $Lang->{'Delete'} = 'Löschen';
    $Lang->{'News Item'} = 'News Beitrag';
    $Lang->{'created by'} = 'erstellt von';

    # Kernel/Output/HTML/Templates/Standard/AdminProductNewsList.tt
    $Lang->{'Add news'} = 'Neue Nachricht';
    $Lang->{'List'} = '';
    $Lang->{'News ID'} = 'Nachricht';
    $Lang->{'Date'} = '';
    $Lang->{'Author'} = 'Autor';
    $Lang->{'Action'} = '';
    $Lang->{'No matches found.'} = '';
    $Lang->{'edit'} = 'bearbeiten';
    $Lang->{'delete'} = 'löschen';

    # Kernel/Output/HTML/Templates/Standard/AgentProductNews.tt
    $Lang->{'Mark as read'} = 'Als gelesen markieren';

    # Kernel/Output/HTML/Templates/Standard/ProductNewsSnippetLogin.tt
    $Lang->{'Close this dialog'} = '';

    return 1;
}

1;
