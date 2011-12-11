$ ->
  $('.content').delegate '.alert-message .close', 'click', ->
    $(this).closest('.alert-message').slideUp('fast', (-> $(this).remove()))

  $('button.delete-user').click ->
    if confirm 'Are you sure you want to delete that user?'
      $(this).disable()
      $(this).html 'Deleting...'

      $.ajax({
        url: '/a/user/' + $(this).data('userId'),
        type: 'delete',
        success: => $(this).closest('tr').fadeOut('fast', (-> $(this).remove()))
      });

  $('button.reset-user-password').click ->
    $(this).disable()
    $(this).html 'Resetting...'

    $.ajax({
      url: '/a/user/' + $(this).data('userId') + '/reset-password',
      type: 'post',
      success: (data) =>
        $(this).enable()
        $(this).html 'Reset password'
        $.flash 'success', "Password was successfully reseted to '" + data.password + "'."
    });

  $('button.delete-subject').click ->
    if confirm 'Are you sure you want to delete that subject?'
      $.ajax({ url: '/a/subject/' + $(this).data('subjectId'), type: 'delete', success: =>
        $(this).closest('tr').fadeOut('fast', (-> $(this).remove()))
      });

$.fn.disable = -> this.attr 'disabled', 'disabled'
$.fn.enable  = -> this.removeAttr 'disabled'

$.flash = (type, msg) ->
  close_button = $('<a/>', { class: 'close', href: '#' }).html('&times;')
  box = $('<div/>', { class: 'alert-message', style: 'display: none' }).addClass(type).html(msg).append(close_button)
  box.appendTo($('#flash')).slideDown('fast')