modulejs.define('HBWFormUser', ['React', 'ReactDOM', 'jQuery'], (React, ReactDOM, jQuery) => React.createClass({
  render () {
    return <div className={this.props.params.css_class} title={this.props.params.tooltip}>
      <span className={this.props.params.label_css}>{this.props.params.label}</span>
      <div className='form-group'>
        <select name={this.props.name} type='text' />
      </div>
    </div>;
  },

  componentDidMount () {
    this.hijack_select2();
  },

  hijack_select2 () {
    const e = jQuery(ReactDOM.findDOMNode(this));
    const select = e.find('select');

    select.select2({
      width:       '100%',
      allowClear:  this.props.params.nullable,
      theme:       'bootstrap',
      placeholder: this.props.params.placeholder || 'User',
      ajax:        {
        url:      '/users/lookup',
        dataType: 'json',
        delay:    250,
        processResults (data, page) {
          return { results: data };
        },
        data (params) {
          return {
            q:    params.term,
            page: params.page
          };
        },
        formatSelection (node) {
          return node.id;
        },
        cache: true
      },
      minimumInputLength: 1
    });

    // kinda hack
    e.find('.select2-selection').height(32);
    e.find('.select2-selection__arrow').height(32);
    e.find('.select2-selection__rendered').height(32);
  }
}));
