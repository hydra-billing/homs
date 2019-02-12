import { withConditions } from '../helpers';

modulejs.define('HBWFormFileList', ['React'], (React) => {
  const FormFileList = React.createClass({
    displayName: 'HBWFormFileList',

    componentDidMount () {
      this.props.onRef(this);
    },

    componentWillUnmount () {
      this.props.onRef(undefined);
    },

    getInitialState () {
      return {
        valid:        true,
        deletedFiles: [],
        links:        JSON.parse(this.props.value) || []
      };
    },

    render () {
      const { links } = this.state;
      let cssClass = this.props.params.css_class;

      if (this.props.hidden) {
        cssClass += ' hidden';
      }

      const { label } = this.props.params;
      const labelCSS = `hbw-checkbox-label ${this.props.params.label_css || ''}`;

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
            {!this.props.disabled && (
              <a href="#" className="fas fa-reply" onClick={e => onClick(e, variant.name)} />
            )}
          </li>;
        } else {
          return <li key={i}>
            <a href={variant.url}>{variant.name}</a>
            &nbsp;
            {!this.props.disabled && (
              <a href="#" className="fas fa-times" onClick={e => onClick(e, variant.name)} />
            )}
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
    },

    serialize () {
      return { [this.props.params.name]: this.state.links.filter(link => !this.state.deletedFiles.includes(link.name)) };
    }
  });

  return withConditions(FormFileList);
});
