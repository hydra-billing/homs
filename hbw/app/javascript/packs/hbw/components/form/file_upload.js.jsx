import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withCallbacks, withConditions, withErrorBoundary } from 'shared/hoc';

modulejs.define('HBWFormFileUpload', ['React'], (React) => {
  class HBWFormFileUpload extends React.Component {
    state = {
      valid:          true,
      files:          [],
      filesCount:     0,
      dragStyleClass: 'attacher'
    };

    componentDidMount () {
      this.props.onRef(this);
    }

    componentWillUnmount () {
      this.props.onRef(undefined);
    }

    render () {
      const {
        name, params, disabled, hidden, fileListPresent, task, env
      } = this.props;

      const { files, dragStyleClass } = this.state;

      const opts = {
        disabled,
        name,
        onChange: this.onChange
      };

      const hiddenValue = JSON.stringify({ files });
      const cssClass = cx(params.css_class, { hidden });
      const errorMessage = env.translator('errors.file_list_field_required');
      const errorMessageCss = cx('alert', 'alert-danger', { hidden: fileListPresent });
      const label = env.bpTranslator(`${task.process_key}.${task.key}.${name}`, {}, params.label);
      const labelCSS = cx('hbw-file-upload-label', params.label_css);

      return (
        <div className={cssClass}>
          <span className={labelCSS}>{label}</span>
          <div className={errorMessageCss}>{errorMessage}</div>
          <div className="form-group">
            <input {...opts} type="file" multiple></input>
            <input name={name} value={hiddenValue} type="hidden"/>
            <div
              className={dragStyleClass}
              onDragEnter={e => this.onDragEnter(e)}
              onDragLeave={e => this.onDragLeave(e)}
              onDragOver={e => e.preventDefault()}
              onDrop={e => this.onDrop(e)}
            >
              <div className='drop_text'>{env.translator('components.file_upload.drag_and_drop')}</div>
            </div>
          </div>
        </div>
      );
    }

    onDragEnter = (event) => {
      event.preventDefault();
      this.setState({ dragStyleClass: 'attacher activated' });
    };

    onDragLeave = (event) => {
      event.preventDefault();
      this.setState({ dragStyleClass: 'attacher' });
    };

    onDrop = (event) => {
      event.preventDefault();
      const files = Array.from(event.dataTransfer.files);
      this.setState({ dragStyleClass: 'attacher' });
      this.readFiles(files);
    };

    onChange = (event) => {
      const files = Array.from(event.target.files);
      this.readFiles(files);
    };

    readFiles = (files) => {
      this.setState({
        files:      [],
        filesCount: files.length
      });

      if (files.length > 0) {
        this.props.trigger('hbw:file-upload-started');

        return files.map(file => this.readFile(file.name, file));
      }

      return null;
    };

    addValue = (name, res) => {
      const { files } = this.state;

      files.push({
        name,
        content: window.btoa(res)
      });

      this.setState({
        files,
        filesCount: this.state.filesCount - 1
      });

      if (this.state.filesCount === 0) {
        this.props.trigger('hbw:file-upload-finished');
      }
    };

    readFile = (name, file) => {
      const fileReader = new FileReader();

      fileReader.onloadend = () => {
        this.addValue(name, fileReader.result);
      };

      return fileReader.readAsBinaryString(file);
    };

    serialize = () => {
      if (this.props.disabled || this.props.hidden) {
        return null;
      } else {
        return { [this.props.params.name]: JSON.stringify({ files: this.state.files }) };
      }
    };
  }

  return compose(withCallbacks, withConditions, withErrorBoundary)(HBWFormFileUpload);
});
