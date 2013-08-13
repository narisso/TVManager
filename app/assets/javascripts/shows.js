$(function() {

	 	var imdb_path = $(location).attr('href')+"/imdb_info"
  		var tvr_path = $(location).attr('href')+"/tvr_info"

		$.ajax(tvr_path, {
		    type: 'GET',
		    success: function(data) {
		    	var genres = $(data).find('#genres_info')
		    	var info = $(data).find('#general_info')
		    	var episodes = $(data).find('#episodes_info')

				$('#tvr_genres').html(genres);	
				$('#tvr_info').html(info);				
				$('#tvr_episodes').html(episodes);				

		    },
		    error: function() { }
		});

  		$.ajax(imdb_path, {
		    type: 'GET',
		    success: function(data) {
		    	$('#imdb_score').html(data);				
		    },
		    error: function() { }
		});

});