$ ->
  $(".alert-message").alert()

  $('button.delete-user').click ->
    $.ajax({
      url: '/a/user/' + $(this).data('userId'),
      type: 'delete',
      success: => $(this).closest('tr').fadeOut('fast', (-> $(this).remove()))
    });

  $('button.reset-user-password').click ->
    $.ajax({
      url: '/a/user/' + $(this).data('userId') + '/reset-password',
      type: 'post'
    });
