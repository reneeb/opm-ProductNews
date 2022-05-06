# --
# Copyright (C) 2011-2022 Perl-Services.de, https://perl-services.de/
# Copyright (C) 2016 Balázs Úr, http://www.otrs-megoldasok.hu/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::hu_ProductNews;

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
        'JS fájlok listája, amelyek mindig betöltődnek az ügyintézői felületnél.';
    $Lang->{'List of JS files to always be loaded for the customer interface.'} =
        'JS fájlok listája, amelyek mindig betöltődnek az ügyfélfelületnél.';
    $Lang->{'List of CSS files to always be loaded for the agent interface.'} =
        'CSS fájlok listája, amelyek mindig betöltődnek az ügyintézői felületnél.';
    $Lang->{'List of CSS files to always be loaded for the customer interface.'} =
        'CSS fájlok listája, amelyek mindig betöltődnek az ügyfélfelületnél.';
    $Lang->{'Frontend module registration for the agent interface.'} =
        'Előtétprogram-modul regisztráció az ügyintézői felülethez.';
    $Lang->{'Product News'} = 'Termékhírek';
    $Lang->{'Frontend module registration for the customer interface.'} =
        'Előtétprogram-modul regisztráció az ügyfélfelülethez.';
    $Lang->{'Own Product News'} = 'Saját termékhírek';
    $Lang->{'Frontend module registration for the product news administration.'} = 'Előtétprogram-modul regisztráció a termékhírek adminisztrációjához.';
    $Lang->{'Create and manage news.'} = 'Hírek létrehozása és kezelése.';
    $Lang->{'Defines the parameters for the dashboard backend. "Group" is used to restrict access to the plugin (e. g. Group: admin;group1;group2;). "Default" indicates if the plugin is enabled by default or if the user needs to enable it manually.'} =
        'Meghatározza a vezérlőpult háttérprogram paramétereit. A „Csoport” használható a hozzáférés korlátozásához a bővítményre (például Csoport: admin;csoport1;csoport2;). Az „Alapértelmezett” jelzi, ha a bővítmény alapértelmezetten engedélyezve van, vagy ha a felhasználónak kézzel kell engedélyeznie azt.';
    $Lang->{'News!'} = 'Hírek!';
    $Lang->{'Dis-/enables displaying the teaser text of a news entry.'} =
        'Engedélyezi vagy letiltja egy hírbejegyzés bevezető szövegének megjelenítését.';
    $Lang->{'Disabled'} = 'Letiltva';
    $Lang->{'Enabled'} = 'Engedélyezve';
    $Lang->{'Dis-/enables displaying the creator of a news entry.'} =
        'Engedélyezi vagy letiltja egy hírbejegyzés létrehozójának megjelenítését.';
    $Lang->{'Dis-/enables edit-/delete link in dashboard for creator and users of group defined in "ProductNews::DashboardEditDeleteGroup".'} =
        'Engedélyezi vagy letiltja a vezérlőpulton a szerkesztés vagy törlés hivatkozást a létrehozónak és a „ProductNews::DashboardEditDeleteGroup” beállításban meghatározott csoport felhasználóinak.';
    $Lang->{'Defines the group name to which the user must belong to see edit/delete link if not creator.'} =
        'Meghatározza azt a csoportnevet, amelyhez a felhasználónak tartoznia kell a szerkesztés vagy törlés hivatkozás megtekintéséhez, ha nem létrehozó.';
    $Lang->{'If enabled, everybody can set the message to "invalid" by clicking "mark as read".'} =
        'Ha engedélyezve van, akkor mindenki „érvénytelenre” állíthatja az üzenetet a „megjelölés olvasottként” hivatkozásra kattintva.';
    $Lang->{'Configurable header for news widgets.'} = 'Beállítható fejléc a hírek felületi elemeknél.';
    $Lang->{'Module to show product news in sidebar or Ticket zoom.'} =
        'Egy modul termékhírek megjelenítéséhez az oldalsávon vagy a jegynagyításon.';
    $Lang->{'Invalidate product news.'} = 'Termékhírek érvénytelenítése.';

    # Kernel/Modules/AdminProductNews.pm
    $Lang->{'We are sorry, you do not have permissions to edit this news item.'} =
        'Sajnáljuk, de nincs jogosultsága a hírek elem szerkesztéséhez.';

    # Kernel/Output/HTML/Templates/Standard/AdminProductNewsForm.tt
    $Lang->{'News Management'} = 'Hírek kezelése';
    $Lang->{'Actions'} = 'Műveletek';
    $Lang->{'Go to overview'} = 'Ugrás az áttekintőhöz';
    $Lang->{'Add/Change News'} = 'Hírek hozzáadása vagy megváltoztatása';
    $Lang->{'Headline'} = 'Szalagcím';
    $Lang->{'A headline for the news is required.'} = 'A szalagcím kötelező a hírekhez.';
    $Lang->{'Teaser'} = 'Bevezető';
    $Lang->{'Teaser is mandatory.'} = 'A bevezető kötelező.';
    $Lang->{'Body'} = 'Törzs';
    $Lang->{'A news text is required.'} = 'A hír törzse kötelező.';
    $Lang->{'Display'} = 'Megjelenítő';
    $Lang->{'Select a display.'} = 'Válasszon egy megjelenítőt.';
    $Lang->{'Invalidation date'} = 'Érvénytelenítési időpont';
    $Lang->{'Open news when user visits dashboard'} = 'Hírek megnyitása, amikor a felhasználó megnézi a vezérlőpultot';
    $Lang->{'Valid'} = 'Érvényes';
    $Lang->{'Save'} = 'Mentés';
    $Lang->{'or'} = 'vagy';
    $Lang->{'Cancel'} = 'Mégse';

    # Kernel/Output/HTML/Templates/Standard/ProductNewsSnippet.tt
    $Lang->{'All News'} = 'Összes hír';
    $Lang->{'Delete'} = 'Törlés';
    $Lang->{'News Item'} = 'Hírek elem';
    $Lang->{'created by'} = 'létrehozta';

    # Kernel/Output/HTML/Templates/Standard/AdminProductNewsList.tt
    $Lang->{'Add news'} = 'Hírek hozzáadása';
    $Lang->{'List'} = 'Lista';
    $Lang->{'News ID'} = 'Hírazonosító';
    $Lang->{'Date'} = 'Dátum';
    $Lang->{'Author'} = 'Szerző';
    $Lang->{'No matches found.'} = 'Nincs találat.';
    $Lang->{'Delete this entry'} = 'Bejegyzés törlése';

    # Kernel/Output/HTML/Templates/Standard/AgentProductNews.tt
    $Lang->{'Mark as read'} = 'Megjelölés olvasottként';

    # Kernel/Output/HTML/Templates/Standard/DashboardProductNews.tt
    $Lang->{'edit'} = 'szerkesztés';
    $Lang->{'delete'} = 'törlés';

    # Kernel/Output/HTML/Templates/Standard/ProductNewsSnippetLogin.tt
    $Lang->{'Close this dialog'} = 'Párbeszédablak bezárása';

    return 1;
}

1;
