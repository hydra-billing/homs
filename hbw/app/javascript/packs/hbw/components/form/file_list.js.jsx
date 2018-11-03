modulejs.define('HBWFormFileList', ['React', 'HBWDeleteIfMixin'], (React, DeleteIfMixin) => React.createClass({
  mixins: [DeleteIfMixin],

  displayName: 'HBWFormFileList',

  getInitialState () {
    return {
      valid:        true,
      deletedFiles: []
    };
  },

  render () {
    let links;
    let cssClass = this.props.params.css_class;

    if (this.hidden) {
      cssClass += ' hidden';
    }

    const { label } = this.props.params;
    const labelCSS = `hbw-checkbox-label ${this.props.params.label_css || ''}`;

    if (this.props.value) {
      links = JSON.parse(this.props.value);
    } else {
      links = [];
    }

    const hiddenValue = JSON.stringify(links.filter(link => !this.state.deletedFiles.includes(link.name)));

    return <div className={cssClass}>
      <input name={this.props.params.name} value={hiddenValue} type="hidden"/>
      <label className={labelCSS}>
        <span>{` ${label}`}</span>
        <ul>
          {this.files(links)}
        </ul>
      </label>
    </div>;
  },

  files (list) {
    const onClick = this.deleteLink;
    const { deletedFiles } = this.state;

    return list.map((variant, i) => {
      if (deletedFiles.includes(variant.name)) {
        return <li className={'danger'}>
          <a href={variant.url}>{variant.name}</a>
          &nbsp;
          <a href="#" className="fa fa-reply" onClick={e => onClick(e, variant.name)}></a>
        </li>;
      } else {
        return <li key={i}>
          <a href={variant.url}>{variant.name}</a>
          &nbsp;
          <a href="#" className="fa fa-times" onClick={e => onClick(e, variant.name)}></a>
        </li>;
      }
    });
  },

  deleteLink (evt, name) {
    const { deletedFiles } = this.state;

    if (deletedFiles.includes(name)) {
      const index = deletedFiles.indexOf(name);
      deletedFiles.splice(index, 1);
    } else {
      deletedFiles.push(name);
    }

    this.setState({ deletedFiles });
  }
}));
