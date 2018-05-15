
"use strict";

var PS = PS || {};

PS.ProductNewsLogin = (function (TargetNS) {

    TargetNS.Init = function() {

        $('.clickProductNewsX').on('click',function() {
            var NewsID = $(this).data('id');


            $('<div id="PNXOverlay" tabindex="-1"><div role="dialog" class="PNXDialog Modal"></div></div>').appendTo('body');
            $('.PNXDialog').append(
                $( '#ProductNewsXExtended_' + NewsID ).html()
            );
            $('body').css({'overflow': 'hidden'});

            $('#PNXOverlay').height($(document).height()).css('top', 0);

            $('.Close').bind('click',function() {
                $('#PNXOverlay').remove();
                $('body').css({
                    'overflow': 'auto'
                });
                $('body').css('min-height', 'auto');
                return false;
            });

            return false;
        });

       $('span[id^="mark_as_read_"]').on( 'click', function() {
            var link    = $(this);
            var news_id = link.attr('id').replace('mark_as_read_', '');

            $.ajax({
                type: "POST",
                url:  Core.Config.Get('Baselink'),
                data : {
                    Action: ActionPrefix + 'ProductNewsMarkRead',
                    NewsID: news_id
                },
                success : function() {
                    link.closest('tr').remove();
                }
            });
        });
    };

    TargetNS.Init();

    return TargetNS;
}(PS.ProductNewsLogin || {} ));
