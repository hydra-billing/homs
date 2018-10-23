(function() {
  var TwitterBootstrapConfirmBox;

  $.fn.twitter_bootstrap_confirmbox = {
    defaults: {
      title: null,
      proceed: "OK",
      proceed_class: "btn proceed",
      cancel: "Cancel",
      cancel_class: "btn cancel",
      fade: false,
      modal_class: ""
    }
  };

  TwitterBootstrapConfirmBox = function(message, element, callback) {
    var $dialog, bootstrap_version;
    bootstrap_version = typeof $().emulateTransitionEnd === 'function' ? parseInt($.fn.tooltip.Constructor.VERSION[0]) : 2;

    switch (bootstrap_version) {
      case 2:
        $dialog = $('<div class="modal hide" id="confirmation_dialog"> <div class="modal-header"> <button type="button" class="close" data-dismiss="modal">×</button> <h3 class="modal-title">...</h3> </div> <div class="modal-body"></div> <div class="modal-footer"></div> </div>');
        break;
      case 3:
        $dialog = $('<div class="modal" id="confirmation_dialog" role="dialog"> <div class="modal-dialog"> <div class="modal-content"> <div class="modal-header"> <button type="button" class="close" data-dismiss="modal">×</button> <h4 class="modal-title">...</h4> </div> <div class="modal-body"></div> <div class="modal-footer"></div> </div> </div> </div>');
        break;
      default:
        $dialog = $('<div class="modal" id="confirmation_dialog" role="dialog"> <div class="modal-dialog"> <div class="modal-content"> <div class="modal-header"> <h4 class="modal-title">...</h4> <button type="button" class="close" data-dismiss="modal">×</button> </div> <div class="modal-body"></div> <div class="modal-footer"></div> </div> </div> </div>');
    }

    $dialog.addClass(element.data("confirm-modal-class") || $.fn.twitter_bootstrap_confirmbox.defaults.modal_class);

    if (element.data("confirm-fade") || $.fn.twitter_bootstrap_confirmbox.defaults.fade) {
      $dialog.addClass("fade");
    }

    $dialog.find(".modal-header .modal-title").html(element.data("confirm-title") || $.fn.twitter_bootstrap_confirmbox.defaults.title || window.top.location.origin);

    $dialog.find(".modal-body").html(message.toString().replace(/\n/g, "<br />"));

    var cancel_buton = $("<a />", { href: "#", "data-dismiss": "modal" });
    cancel_buton.html(element.data("confirm-cancel") || $.fn.twitter_bootstrap_confirmbox.defaults.cancel);
    cancel_buton.addClass($.fn.twitter_bootstrap_confirmbox.defaults.cancel_class);
    cancel_buton.addClass(element.data("confirm-cancel-class") || (bootstrap_version === 4 ? "btn-secondary" : void 0) || "btn-default");
    cancel_buton.click(function(event) {
      event.preventDefault();
      return $dialog.modal("hide");
    });
    $dialog.find(".modal-footer").append(cancel_buton);

    var confirm_button = $("<a />", { href: "#" });
    confirm_button.html(element.data("confirm-proceed") || $.fn.twitter_bootstrap_confirmbox.defaults.proceed);
    confirm_button.addClass($.fn.twitter_bootstrap_confirmbox.defaults.proceed_class);
    confirm_button.addClass(element.data("confirm-proceed-class") || "btn-primary");
    confirm_button.click(function(event) {
      event.preventDefault();
      $dialog.modal("hide");
      return callback();
    });
    $dialog.find(".modal-footer").append(confirm_button);

    $dialog.on('keypress', function(e) {
              if (e.keyCode === 13) { return $('.modal-footer a:last').trigger('click'); }
            }).on("hidden hidden.bs.modal", function() {
              return $(this).remove();
            });

    $dialog.modal("show").appendTo(document.body);
  };

  if (typeof $().modal === 'function') {
    $.rails.allowAction = function(element) {
      $(element).blur();

      var message = element.data("confirm");
      var answer = false;

      if (!message) {
        return true;
      }

      if ($.rails.fire(element, "confirm")) {
        TwitterBootstrapConfirmBox(message, element, function() {
          if ($.rails.fire(element, "confirm:complete", [answer])) {
            var allowAction = $.rails.allowAction;

            $.rails.allowAction = function() {
              return true;
            };

            if (element.get(0).click) {
              element.get(0).click();
            } else if (typeof Event !== "undefined" && Event !== null) {
              var evt = new Event("click", { bubbles: true, cancelable: true, view: window, detail: 0, screenX: 0,
                                             screenY: 0, clientX: 0, clientY: 0, ctrlKey: false, altKey: false,
                                             shiftKey: false, metaKey: false, button: 0,
                                             relatedTarget: document.body.parentNode });

              element.get(0).dispatchEvent(evt);
            } else if ($.isFunction(document.createEvent)) {
              var evt = document.createEvent("MouseEvents");
              evt.initMouseEvent("click", true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, document.body.parentNode);

              element.get(0).dispatchEvent(evt);
            }

            return $.rails.allowAction = allowAction;
          }
        });
      }
      return false;
    };
  }
}).call(this);
