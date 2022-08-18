// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//= require rails-ujs
//= require turbolinks
//= require jquery
//= require jquery-ui/widgets/datepicker
//= require jquery-ui/i18n/datepicker-ja
//= require_tree .

/* === 画面制御 =========================================================== */

function submit(url, formname, method){
	
    var form = document.forms[0];
    if (formname != null) {
/*alert("formname = " + formname);*/
        form = document.forms[formname];
    }
    if (method == null || method == '') {
        method = 'POST'
    }

/*alert("url = " + url);*/
/*alert("method = " + method);*/

    form.action = url;
    form.method = method;
    form.submit();
    
/*alert("submitしましたよ");*/
}

function sort(col, order){
    var formname = 'form_search';
    var form = document.forms[formname];
    document.getElementById('sort' ).value=col;
    document.getElementById('order').value=order;

    submit('', formname, 'GET');
}

function pop(url, h, winName){
	if(h == undefined || h == null){
		h = 300;
	}
    var win = window.open( url, winName, 'width=700, height=' + h + ', menubar=no, toolbar=no, scrollbars=yes, resizable=yes' );
    win.focus();

}

function datePick() {
    $('input:text[class="ymd"]').datepicker({ dateFormat: 'yy/mm/dd'
/*        showOn: 'both',
        buttonImage: '/images/calendar.gif',
        buttonImageOnly: true*/
    });
}

function datePickShort() {
    $('input:text[class="ymd_short"]').datepicker({ dateFormat: 'yy/mm/dd'
/*        showOn: 'both',
        buttonImage: '/images/calendar.gif',
        buttonImageOnly: true*/
    });
}

var numeric_classes = 'input.fmt-formatted-number';

function loadWithSafeComma() {
	$(numeric_classes).each(function(){
		$(this).val(insertComma($(this).val()));
	});
}

function focusWithSafeComma() {
	$(numeric_classes).focus(function(){
		$(this).val(delComma($(this).val()));
	});
	$(numeric_classes).blur(function(){
		$(this).val(insertComma($(this).val()));
	});
}

function submitWithSafeComma() {
	$("form").submit(function() {
		$(numeric_classes).each(function(){
			$(this).val(delComma($(this).val()));
		});
	});
}

$(function() {
    datePick();
    datePickShort();
    //colorRow();
	loadWithSafeComma();
    submitWithSafeComma();
	focusWithSafeComma();
});

$(document).on('turbolinks:render', function() {
    datePick();
    datePickShort();
    //colorRow();
	loadWithSafeComma();
    submitWithSafeComma();
	focusWithSafeComma();
});

function showCalClearBtn(obj) {
	var calObj = $(obj).prev('input:text[class^="ymd"]');
	$(calObj).val('');
}

/* === 共通関数 ================================================================= */
//カンマ挿入関数
function insertComma(sourceStr) {
	var destStr = sourceStr;
	var tmpStr = "";
	while (destStr != (tmpStr = destStr.replace(/^([+-]?\d+)(\d\d\d)/,"$1,$2"))) {
		destStr = tmpStr;
	}
	return destStr;
}

//カンマ削除関数
function delComma(w) {
	var z = w.replace(/,/g,"");
	return (z);
}
