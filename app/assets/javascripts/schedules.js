function moveEvent(event, delta) {
	jQuery.ajax({
		data : 'id=' + event.id + '&title=' + event.title + '&hour_delta=' + delta.hours() + '&minute_delta=' + delta.minutes(),
		dataType : 'script',
		type : 'post',
		url : "/schedules/move"
	});
}

function resizeEvent(event, delta) {
	jQuery.ajax({
		data : 'id=' + event.id + '&title=' + event.title + '&hour_delta=' + delta.hours() + '&minute_delta=' + delta.minutes(),
		dataType : 'script',
		type : 'post',
		url : "/schedules/resize"
	});
}

function showEventDetails(event) {
	$("#desc_dialog").find('.modal-header').show();
	$('#event_desc').empty();
	$('#edit_event').html("<a href = 'javascript:void(0);' onclick ='editEvent(" + event.id + ")' class='btn btn-sm'>Edit</a>");
	
		title = "<h3>"+event.title+"</h3>";
		title += "<h4>Class: "+event.description.class_name+"</h4>";
		title += "<h4>Date: "+moment(event.start).format('MM/DD/YYYY')+"</h4>";		
		title += "<h4>Timings: "+moment(event.start).format('h:mm a')+" - "+moment(event.end).format('h:mm a')+"</h4>";
		title += "<p>"+event.description.description+"<p>";
		$('#delete_event').html("<a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + false + ")' class='btn btn-sm'>Delete</a>");
	
	
	$('#desc_dialogLabel').html(title);
	$('#desc_dialog').modal('show');

}

function show_list_events_details (event) {
  $("#desc_dialog").find('.modal-header').show();
	$('#event_desc').empty();
	$('#edit_event').html("<a href = 'javascript:void(0);' onclick ='editEvent(" + event.id + ")' class='btn btn-sm'>Edit</a>");
	
		title = "<h3>"+event.title+"</h3>";
		title += "<h4>Class: "+event.class_name+"</h4>";
		title += "<h4>Date: "+moment(event.date).format('MM/DD/YYYY')+"</h4>";		
		title += "<h4>Timings: "+moment(event.starttime).format('h:mm a')+" - "+moment(event.endtime).format('h:mm a')+"</h4>";
		title += "<p>"+event.description+"<p>";
		$('#delete_event').html("<a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + false + ")' class='btn btn-sm'>Delete</a>");
	
	
	$('#desc_dialogLabel').html(title);
	$('#desc_dialog').modal('show');
}


function showEventDetailsUser(event) {
	$("#desc_dialog").find('.modal-header').show();
	$('#event_desc').empty();
	// $('#edit_event').html("<a href = 'javascript:void(0);' onclick ='editEvent(" + event.id + ")' class='btn btn-sm'>Edit</a>");

	    title = "<h3>"+event.title+"</h3>";
		title += "<h4>Class: "+event.class_name+"</h4>";
		title += "<h4>Date: "+moment(event.date).format('MM/DD/YYYY')+"</h4>";		
		title += "<h4>Timings: "+moment(event.starttime).format('h:mm a')+" - "+moment(event.starttime).format('h:mm a')+"</h4>";
		title += "<p>"+event.description+"<p>";
	
	$('#desc_dialogLabel').html(title);
	$('#desc_dialog').modal('show');

}

function editEvent(event_id) {
	jQuery.ajax({
		url : "/schedules/" + event_id + "/edit",
		success : function(data) {
			$('#event_desc').empty();
			$('#event_desc').html(data['form']);
		}
	});
}

function deleteEvent(event_id, delete_all) {
	var r = confirm("Are you Sure?");
		if (r == true) {
		    jQuery.ajax({
			// data : 'authenticity_token=' + authenticity_token + '&delete_all=' + delete_all,
			data : '&delete_all=' + delete_all,
			dataType : 'script',
			type : 'delete',
			url : "/schedules/" + event_id,
			success : refetch_events_and_close_dialog
		});		
	} 
	
}

function refetch_events_and_close_dialog() {
	$('#calendar').fullCalendar('refetchEvents');
	// $('.dialog:visible').dialog('destroy');
	$('.modal.fade.in').modal('hide');
	

	$.get("/schedules/list_schedules",{event: {}}, function(data) {
		$('#eventlisting').empty();
		$('#eventlisting').html(data);

	});
}

function showPeriodAndFrequency(value) {

	switch (value) {
		case 'Daily':
			$('#period').html('day');
			$('#frequency').show();
			break;
		case 'Weekly':
			$('#period').html('week');
			$('#frequency').show();
			break;
		case 'Monthly':
			$('#period').html('month');
			$('#frequency').show();
			break;
		case 'Yearly':
			$('#period').html('year');
			$('#frequency').show();
			break;

		default:
			$('#frequency').hide();
	}
}

function showdateupto(value) {
	if (value == "Until") {
		$("#datepicker").val();
		$("#dateupto").show();
	} else {
		$("#dateupto").hide();
	}

}


$(document).ready(function() {
	$.authenticityToken = function() {
		return $('#authenticity-token').attr('content');
	};

	$('#create_event, #desc_dialog').on('submit', "#event_form", function(event) {
		var $spinner = $('.spinner');
		event.preventDefault();
		$.ajax({
			type : "POST",
			data : $(this).serialize(),
			url : $(this).attr('action'),
			beforeSend : show_spinner,
			complete : hide_spinner,
			success : refetch_events_and_close_dialog,
			error : handle_error
		});

		function show_spinner() {
			$spinner.show();
		}

		function hide_spinner() {
			$spinner.hide();
		}

		function handle_error(xhr) {
			alert(xhr.responseText);
		}

	});
});

$(document).on("click",'#new_schedule',function(event) {
		event.preventDefault();
		var url = $(this).attr('href');
		var user_id = $(this).data('userid');
		$.ajax({
			url : url,
			beforeSend : function() {
				$('#loading').show();
			},
			complete : function() {
				$('#loading').hide();
			},
			success : function(data) {
				// $('#create_event').replaceWith(data['form']);
				$('#eventModalLabel').html('New Schedule');
				$('#create_event').empty();
				$('#create_event').html(data['form']);
				$('#create_event').find("#schedule_user_id").val(user_id);
							
				$('#eventModal').modal('show');  
			}
		});
	});

$(document).on("click","#eventlist",function(){		
	var user_id=$("#event_user_id").val();
	$.get("/schedules/list_schedules",{schedule: {user_id:user_id}},function(data){
		$("#eventlisting").empty();
		$("#eventlisting").html(data);
	});
});

