$( document ).ready(function() {
  $('#shows_main_table').tablesorter({widgets: ['zebra']});
  $('#search_result_table').tablesorter({widgets: ['zebra']});
  $('#downloads_table').tablesorter({widgets: ['zebra']});

  $('#shows_search_lookup_form').submit(function() {
    $('#notice').text("");
    $.get(this.action, $(this).serialize(), null, 'script');
    return false;
  });

  $('#search_result_table').on('click', 'tr', function() {
    var id = $(this).find('td.id').text();
    if (id) {
      var name = $(this).find('td.name').text();
      reply = confirm('Create show ' + name + ' with tvrage id ' + id + '?');
      if (reply) {
        $.post("/shows.json", { "show[name]" : $(this).find('td.name').text(), "show[tvrage_id]" : $(this).find('td.id').text(), "show[hd]" : "true" }, function(response) {
          $('#notice').text("Created show " + response.name + " with tvrage id " + response.tvrage_id + " and tvillion id " + response.id + ".");
        }, 'json');
      }
    }
  });

  $('#loading-indicator').hide().ajaxStart(function() {
    $(this).show();
  }).ajaxStop(function() {
    $(this).hide();
  });

  $("div.progressbar").each (function () {
    var element = this;
    $(element).progressbar({
      value: parseInt($(element).attr("percent"))
    });
  });
});
