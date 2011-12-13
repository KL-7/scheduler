$ ->
  $('.content').delegate '.alert-message .close', 'click', ->
    $(this).closest('.alert-message').slideUp('fast', (-> $(this).remove()))

  $('button.reset-user-password').click ->
    $(this).disable().html 'Resetting...'

    $.ajax({
      url: '/a/user/' + $(this).data('userId') + '/reset-password',
      type: 'post',
      success: (data) =>
        $(this).enable().html 'Reset password'
        $.flash 'success', "Password for " + data.username + " was successfully reset to '" + data.password + "'."
    });

  $('.content').delegate 'button.delete-record', 'click', ->
    if confirm 'Are you sure you want to delete that record?'
      $(this).disable().html 'Deleting...'

      $.ajax({
        url: $(this).data('deletePath') + '/' + $(this).data('recordId'),
        type: 'delete',
        success: => $(this).closest('tr').fadeOut('fast', (-> $(this).remove())),
        error: =>
          $(this).enable().html 'Delete'
          $.flash 'error', "Failed to delete record."
      });

$.fn.disable = -> this.attr 'disabled', 'disabled'
$.fn.enable  = -> this.removeAttr 'disabled'

$.flash = (type, msg) ->
  close_button = $('<a/>', { class: 'close', href: '#' }).html('&times;')
  box = $('<div/>', { class: 'alert-message', style: 'display: none' }).addClass(type).html(msg).append(close_button)
  box.appendTo($('#flash')).slideDown('fast')