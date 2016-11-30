// --
// Core.Agent.ActionCommonDialog.js - provides dynamic oading of display text from frontend module
// Copyright (C) 2006-2014 c.a.p.e. IT GmbH, http://www.cape-it.de
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core = Core || {};
Core.UI = Core.UI || {};

/**
 * @namespace
 * @exports TargetNS as Core.Agent.ActionCommonDialog
 * @description 
 *      This namespace contains the special module functions for the search.
 */
Core.UI.Dialog = (function (TargetNS) {

    /**
     * @function
     * @param {String} Action which is used in framework right now.
     * @param {String} ID of the entry to be retrieved.
     * @return nothing
     */

    TargetNS.DynamicContentDialog = function ( Action, ID, Mode, Title ) {

        if (!Action) {
            Action = 'AgentActionDynamicContentDialog';
        }
        
        var Data = {
            Action: Action,
            ID: ID,
            Mode: Mode
        };

        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            Data,
            function (HTML) {
                Core.UI.Dialog.ShowContentDialog(
                        $.parseHTML(HTML), 
                        Title, 
                        '20px',
                        'Center',
                        true,
                        [],
                        false
                );
            },
            'html'
        );
    };

    TargetNS.NewsAutoOpenRead = function(ID) {
        var Data = {
            Action: 'AgentProductNewsMarkRead',
            ID: ID,
            Mode: 'ReadAutoOpen'
        };

        if ( Core.Config.Get('Action').match(/^Customer/) ) {
            Data.Action = 'CustomerProductNewsMarkRead';
        }

        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            Data,
            function() {},
            'json'
        );
    };

    return TargetNS;
}(Core.UI.Dialog || {}));
