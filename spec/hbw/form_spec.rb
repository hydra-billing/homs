describe HBW::Form do
  let(:form_config) do
    YAML.load 'form:
  css_class: col-xs-12 col-sm-6 col-md-5 col-lg-4
  fields:
  - name: static1
    type: static
    html: <div class="alert alert-info"><h4>You are performing this task in <b>Employee</b> role</h4> <small>In production mode this task is invisible for manager and should be done by employee</small></div>
    css_class: col-xs-12
  - name: group1
    type: group
    label: Request Resolution
    css_class: col-xs-12
    fields:
    - name: homsOrderDataResolutionText
      type: text
      rows: 3
      label: Resolution
      css_class: col-xs-12
      editable: false
  - name: group2
    type: group
    label: Request Data
    css_class: col-xs-12
    fields:
    - name: homsOrderDataBeginDate
      type: datetime
      label: Begin Date
      css_class: col-xs-6 col-sm-4 col-md-3
      format: DD.MM.YYYY
    - name: homsOrderDataEndDate
      type: datetime
      label: End Date
      css_class: col-xs-6 col-sm-4 col-md-3
      format: DD.MM.YYYY
    - name: homsOrderDataMotivationText
      type: text
      rows: 3
      label: Motivation
      css_class: col-xs-12
  - name: homsOrderDataAdjustResult
    type: submit_select
    css_class: col-xs-12
    options:
    - name: Resend
      value: Resend
      css_class: btn btn-primary
    - name: Cancel Request
      value: Cancel
      css_class: btn btn-danger'
  end

  let(:request_data) do
    {
        'form_data' =>
            {
                'homsOrderDataResolutionText' => '',
                'homsOrderDataBeginDate'      => '',
                'homsOrderDataEndDate'        => '',
                'homsOrderDataMotivationText' => '',
                'homsOrderDataAdjustResult'   => 'Resend'
            }
    }
  end

  it 'does fields coercing with empty strings' do
    form = HBW::Form.new(form_config.fetch('form').merge('processDefinition' => {}, 'task' => {}))
    expect(form.extract_and_coerce_values(request_data['form_data'])).to eq({
                                                                                'homsOrderDataBeginDate'      => nil,
                                                                                'homsOrderDataEndDate'        => nil,
                                                                                'homsOrderDataMotivationText' => '',
                                                                                'homsOrderDataAdjustResult'   => 'Resend'
                                                                            })
  end
end
