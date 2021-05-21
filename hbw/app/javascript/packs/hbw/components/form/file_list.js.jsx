import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withConditions, withErrorBoundary } from 'shared/hoc';

modulejs.define('HBWFormFileList', ['React'], (React) => {
  class HBWFormFileList extends React.Component {
    state = {
      valid:        true,
      deletedFiles: [],
      links:        (this.props.value && JSON.parse(this.props.value)) || []
    };

    componentDidMount () {
      this.props.onRef(this);
    }

    componentWillUnmount () {
      this.props.onRef(undefined);
    }

    render () {
      const {
        name, params, hidden, task, env
      } = this.props;

      const { links, deletedFiles } = this.state;

      const cssClass = cx(params.css_class, 'hbw-file-list', { hidden });

      const label = env.bpTranslator(`${task.process_key}.${task.key}.${name}`, {}, params.label);
      const labelCSS = cx('hbw-file-list-label', params.label_css);

      const hiddenValue = JSON.stringify(links.filter(link => !deletedFiles.includes(link.name)));

      return <div className={cssClass}>
        <div className="form-group">
          <input name={params.name} value={hiddenValue} type="hidden"/>
          <label className={labelCSS}>
            <span>{` ${label}`}</span>
            {params.description?.placement === 'top' && this.renderDescription()}
            <ul>
              {this.files(links)}
            </ul>
          </label>
        </div>
      </div>;
    }

    renderDescription = () => {
      const { placement, text } = this.props.params.description;

      return <div className="description" data-test={`description-${placement}`}>{text}</div>;
    }

    files = (list) => {
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
    };

    deleteLink = (evt, name) => {
      const { deletedFiles } = this.state;

      if (deletedFiles.includes(name)) {
        const index = deletedFiles.indexOf(name);
        deletedFiles.splice(index, 1);
      } else {
        deletedFiles.push(name);
      }

      this.setState({ deletedFiles });
    };

    serialize = () => {
      if (this.props.disabled || this.props.hidden) {
        return null;
      } else {
        const { links, deletedFiles } = this.state;

        return { [this.props.params.name]: JSON.stringify(links.filter(link => !deletedFiles.includes(link.name))) };
      }
    };
  }

  return compose(withConditions, withErrorBoundary)(HBWFormFileList);
});
