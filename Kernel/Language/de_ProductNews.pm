# --
# Copyright (C) 2011-2022 Perl-Services.de, https://perl-services.de/
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
    $Lang->{'Product News'} = 'Produktneuigkeiten';
    $Lang->{'Frontend module registration for the customer interface.'} = '';
    $Lang->{'Own Product News'} = 'Eigene Produktneuigkeiten';
    $Lang->{'Frontend module registration for the product news administration.'} = '';
    $Lang->{'Create and manage news.'} = 'Nachrichten erstellen und verwalten.';
    $Lang->{'Defines the parameters for the dashboard backend. "Group" is used to restrict access to the plugin (e. g. Group: admin;group1;group2;). "Default" indicates if the plugin is enabled by default or if the user needs to enable it manually.'} = '';
    $Lang->{'News!'} = 'Nachrichten!';
    $Lang->{'Dis-/enables displaying the teaser text of a news entry.'} = 'Schaltet die Anzeige des Teasertextes einer Neuigkeit an bzw. aus.';
    $Lang->{'Disabled'} = 'Deaktiviert';
    $Lang->{'Enabled'} = 'Aktiviert';
    $Lang->{'Dis-/enables displaying the creator of a news entry.'} = '';
    $Lang->{'Dis-/enables edit-/delete link in dashboard for creator and users of group defined in "ProductNews::DashboardEditDeleteGroup".'} = '';
    $Lang->{'Defines the group name to which the user must belong to see edit/delete link if not creator.'} = '';
    $Lang->{'If enabled, everybody can set the message to "invalid" by clicking "mark as read".'} = '';
    $Lang->{'Configurable header for news widgets.'} = 'Konfigurierbare Überschriften für News-Widget';
    $Lang->{'Module to show product news in sidebar or Ticket zoom.'} = 'Modul zur Anzeige der Produktneuigkeiten in der Seitenleiste der Ticketansicht'; 
    $Lang->{'Invalidate product news.'} = 'Setze Produktneuigkeit auf ungültig.';

    # Kernel/Modules/AdminProductNews.pm
    $Lang->{'We are sorry, you do not have permissions to edit this news item.'} =
        'Sie haben keine Berechtigung diesen News-Eintrag zu bearbeiten.';

    # Kernel/Output/HTML/Templates/Standard/AdminProductNewsForm.tt
    $Lang->{'News Management'} = 'Nachrichten verwalten';
    $Lang->{'Actions'} = 'Aktionen';
    $Lang->{'Go to overview'} = 'Zur Übersicht gehen';
    $Lang->{'Add/Change News'} = 'Nachricht hinzufügen/ändern';
    $Lang->{'Headline'} = 'Überschrift';
    $Lang->{'A headline for the news is required.'} = 'Eine Überschrift für die Neuigkeit muss angegeben werden.';
    $Lang->{'Teaser'} = 'Kurztext';
    $Lang->{'Teaser is mandatory.'} = 'Der Kurztext muss angegeben werden.';
    $Lang->{'Body'} = 'Text';
    $Lang->{'A news text is required.'} = 'Ein Nachrichtentext muss angegeben werden.';
    $Lang->{'Display'} = 'Anzeige';
    $Lang->{'Select a display.'} = 'Wähle eine Anzeige.';
    $Lang->{'Invalidation date'} = 'Nachricht gültig bis';
    $Lang->{'Open news when user visits dashboard'} = 'Nachricht öffnen wenn Agenten das Dashboard öffnen';
    $Lang->{'Valid'} = 'Gültig';
    $Lang->{'Save'} = 'Speichern';
    $Lang->{'or'} = 'oder';
    $Lang->{'Cancel'} = 'Abbrechen';

    # Kernel/Output/HTML/Templates/Standard/ProductNewsSnippet.tt
    $Lang->{'All News'} = 'Alle Nachrichten';
    $Lang->{'Delete'} = 'Löschen';
    $Lang->{'News Item'} = 'News Beitrag';
    $Lang->{'created by'} = 'erstellt von';

    # Kernel/Output/HTML/Templates/Standard/AdminProductNewsList.tt
    $Lang->{'Add news'} = 'Neue Nachricht';
    $Lang->{'List'} = 'Liste';
    $Lang->{'News ID'} = 'Nachricht';
    $Lang->{'Date'} = 'Datum';
    $Lang->{'Author'} = 'Autor';
    $Lang->{'No matches found.'} = 'Keine Treffer gefunden.';
    $Lang->{'Delete this entry'} = '';

    # Kernel/Output/HTML/Templates/Standard/AgentProductNews.tt
    $Lang->{'Mark as read'} = 'Als gelesen markieren';

    # Kernel/Output/HTML/Templates/Standard/DashboardProductNews.tt
    $Lang->{'edit'} = 'bearbeiten';
    $Lang->{'delete'} = 'löschen';

    # Kernel/Output/HTML/Templates/Standard/ProductNewsSnippetLogin.tt
    $Lang->{'Close this dialog'} = 'Diesen Dialog schließen';

    return 1;
}

1;
