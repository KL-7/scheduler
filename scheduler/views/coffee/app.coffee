$ ->
  $('.content').delegate '.alert-message .close', 'click', ->
    $(this).closest('.alert-message').slideUp('fast', (-> $(this).remove()))

  $('button.delete-user').click ->
    if confirm 'Are you sure you want to delete that user?'
      $.ajax({ url: '/a/user/' + $(this).data('userId'), type: 'delete', success: =>
        $(this).closest('tr').fadeOut('fast', (-> $(this).remove()))
      });

  $('button.reset-user-password').click ->
    $.ajax({ url: '/a/user/' + $(this).data('userId') + '/reset-password', type: 'post' });

  $('button.delete-subject').click ->
    if confirm 'Are you sure you want to delete that subject?'
      $.ajax({ url: '/a/subject/' + $(this).data('subjectId'), type: 'delete', success: =>
        $(this).closest('tr').fadeOut('fast', (-> $(this).remove()))
      });