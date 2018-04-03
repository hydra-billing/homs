modulejs.define 'HBWFormFileUpload',
  ['React', 'jQuery', 'HBWDeleteIfMixin', 'HBWCallbacksMixin'],
  (React, jQuery, DeleteIfMixin, CallbacksMixin) ->
    React.createClass
      mixins: [DeleteIfMixin, CallbacksMixin]

      getInitialState: ->
        { value: '', valid: true, files: [], files_count: 0}

      render: ->
        opts = {
          name: @props.params.name
          onChange: @onChange
        }

        cssClass = @props.params.css_class
        cssClass += ' hidden' if this.hidden

        label = @props.params.label
        labelCss = @props.params.label_css

        `<div className={cssClass}>
          <span className={labelCss}>{label}</span>
          <div className="form-group">
            <input {...opts} type="file" multiple></input>
            <input name={this.props.params.name} value={this.state.value} type="hidden"/>
          </div>
        </div>`

      onChange: (event) ->
        @trigger('hbw:file-upload-started')
        $el = event.target
        files = Array.from($el.files)

        @state.value = ''
        @state.files = []
        @state.files_count = files.length

        for file in files
          @readFiles(file.name, file)

      addValue: (name, res) ->
        @state.files.push({name: name, content: window.btoa(res)})
        @state.value = JSON.stringify(@state.files)

        @state.files_count = @state.files_count - 1

        if (@state.files_count == 0)
          @trigger('hbw:file-upload-finished')

      readFiles: (name, file) ->
        file_reader = new FileReader()
        file_reader.onloadend = () =>
          @addValue(name, file_reader.result)
        file_reader.readAsBinaryString(file)
