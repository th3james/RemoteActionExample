modalTemplate = """
  <div class="modal">
    <div class="modal-dialog">
      <div class="modal-content">
      </div>
    </div>
  </div>
"""

class window.RemoteModalView
  constructor: (srcEl)->
    @config = RemoteHelpers.extractAttributes(srcEl)
    RemoteHelpers.requireAttributes(@config, ['modal-url'])

    @$el = $(modalTemplate)
    $('body').append(@$el)
    @$el.modal('show')

  setHtml: (html) ->
    @$el.find('.modal-content').html(html)

  submitForm: (form) ->
    $.post(
      form.attr('action'), form.serialize()
    ).done(=>
      @close()
      UpdateableViews.updateViewsForModels(@config['mutates-models'])
    )

  bindToForm: ->
    form = @$el.find('form')
    form.on('submit', (e) =>
      e.preventDefault()
      @submitForm(form)
    )

    cancelButton = @$el.find('[data-action="cancel"]')
    cancelButton.on('click', (e) =>
      e.preventDefault()
      @close()
    )
  
  render: ->
    deferred = $.Deferred()

    $.get(@config['modal-url']).done((body) =>
      @setHtml(body)
      @bindToForm()
      deferred.resolve()

    ).fail((response) =>
      console.log("Error fetching modal content:")
      console.log(response)
      @setHtml("Unable to load content, please reload the page")
      deferred.reject(
        new Error("Unable to load remote view from '#{@config['modal-url']}'")
      )
    )

    return deferred.promise()

  close: =>
    @$el.modal('hide')
    @$el.remove()

RemoteHelpers.onDataAction('remote_modal', 'click', (event) ->
  view = new RemoteModalView(event.currentTarget)
  view.render()
)
