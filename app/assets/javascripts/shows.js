$(function() {
  $('#search_result_table').tablesorter();
  //$('#search_result_table').tablesorter({ sortList: [[1,0]] });

  $('#shows_search_lookup_form').submit(function() {
    $.get(this.action, $(this).serialize(), null, 'script');
    $('#search_result_table').trigger('update');
    return false;
  });

  $('#search_result_table tr').die('click').live('click', function() {
    var id = $(this).find('td.id').text();
    var name = $(this).find('td.name').text();
    reply=confirm('Create show ' + name + ' with tvrage id ' + id + '?');
    if (reply) {
      $.post("/shows.json", { "show[name]" : $(this).find('td.name').text(), "show[tvrage_id]" : $(this).find('td.id').text(), "show[hd]" : "true" }, function(response) {
        $('#notice').text("Created show " + response.name + " with tvrage id " + response.tvrage_id + " and tvillion id " + response.id + ".");
      }, 'json');
    }
  });
});