$(() => {
	let parent = $('.edit-button').closest('.question_container');
	$('.edit-button').on('click', function() {
		parent.on('click', '.condition-class', function() {
			let x = $('#content');
			if (x.css('display') === "none") {
				x.show();
			} else {
				x.hide();
			}
		});
	});
});
