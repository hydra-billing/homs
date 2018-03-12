modulejs.define 'HBWFormGroup', ['React', 'HBWFormDatetime', \
  'HBWFormSubmitSelect', 'HBWFormUser', 'HBWFormSelect', \
  'HBWFormString', 'HBWFormText', 'HBWFormCheckbox', 'HBWFormStatic', \
  'HBWDeleteIfMixin', 'HBWFormSelectTable', 'HBWFormFileList'],
  (React, Datetime, SubmitSelect, User, Select, String, Text, Checkbox, Static, DeleteIfMixin, SelectTable, FileList) ->
    React.createClass
      mixins: [DeleteIfMixin]

      render: ->
        inputCSS = 'tab-panel form-group ' + @props.params.css_class
        inputCSS += ' hidden' if this.hidden

        `<div className={inputCSS}>
           <ul className='nav nav-tabs' role='tablist'>
             <li className='active' role='presentation' title={this.props.params.tooltip}>
               <a role='tab'>{this.props.params.label}</a>
             </li>
           </ul>
           <div className='tab-content' title={this.props.params.tooltip}>
             <div className='row'>
               {this.iterateControls(this.props.params.fields)}
             </div>
           </div>
         </div>`

      iterateControls: (fields) ->
        self = @
        @controls = fields.map (field) ->
          if field.delimiter
            `<div key={field['name']}>{self.formControl(field['name'], field)}<div className='clearfix'></div></div>`
          else
            `<div key={field['name']}>{self.formControl(field['name'], field)}</div>`

      formControl: (name, params) ->
        opts =
          name: name
          params: params
          value: @props.variables[name]
          formSubmitting: @props.formSubmitting
          env: @props.env

        switch params.type
          when 'group'           then `<Group         {...opts} variables={this.props.variables}/>`
          when 'datetime'        then `<Datetime      {...opts}/>`
          when 'select'          then `<Select        {...opts}/>`
          when 'select_table'    then `<SelectTable   {...opts}/>`
          when 'submit_select'   then `<SubmitSelect  {...opts}/>`
          when 'checkbox'        then `<Checkbox      {...opts}/>`
          when 'user'            then `<User          {...opts}/>`
          when 'string'          then `<String        {...opts}/>`
          when 'text'            then `<Text          {...opts}/>`
          when 'static'          then `<Static        {...opts}/>`
          when 'file_list'       then `<FileList      {...opts}/>`
          else `<p>{name}: Unknown control type {params.type}</p>`
