// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require jquery.ui.autocomplete
//= require js-routes
//= require_tree .

$(function() {

 // Below is the name of the textfield that will be autocomplete    
    $('#top_search').autocomplete({
 // This shows the min length of charcters that must be typed before the autocomplete looks for a match.
            minLength: 2,
 // This is the source of the auocomplete suggestions. In this case a list of names from the people controller, in JSON format.
            source: Routes.shows_path(),
  // This updates the textfield when you move the updown the suggestions list, with your keyboard. In our case it will reflect the same value that you see in the suggestions which is the person.given_name.
            focus: function(event, ui) {
                $('#top_search').val(ui.item.name);
                return false;
            },
 // Once a value in the drop down list is selected, do the following:
            select: function(event, ui) {
 // place the person.given_name value into the textfield called 'select_origin'...
                $('#top_search').val(ui.item.name);
 // and place the person.id into the hidden textfield called 'link_origin_id'. 
        $('#top_search_id').val(ui.item.tvr_id);
                return false;
            }
        })

 // The below code is straight from the jQuery example. It formats what data is displayed in the dropdown box, and can be customized.
        .data( "uiAutocomplete" )._renderItem = function( ul, item ) {
            return $( "<li></li>" )
                .data( "item.autocomplete", item )
 // For now which just want to show the person.given_name in the list.
                .append( "<a>" + item.name + "</a>" )
                .appendTo( ul );
        };
});