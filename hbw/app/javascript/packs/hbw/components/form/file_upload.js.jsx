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
      const opts = {
        disabled: this.props.disabled,
        name:     this.props.params.name,
        onChange: this.onChange
      };

      const hiddenValue = JSON.stringify({ files: this.state.files });

      let cssClass = this.props.params.css_class;
      if (this.props.hidden) {
        cssClass += ' hidden';
      }

      const errorMessage = this.props.env.translator('errors.file_list_field_required');
      let errorMessageCss = 'alert alert-danger';

      if (this.props.fileListPresent) {
        errorMessageCss += ' hidden';
      }

      const { label } = this.props.params;
      const labelCss = this.props.params.label_css;

      return (
        <div className={cssClass}>
          <span className={labelCss}>{label}</span>
          <div className={errorMessageCss}>{errorMessage}</div>
          <div className="form-group">
            <input {...opts} type="file" multiple></input>
            <input name={this.props.params.name} value={hiddenValue} type="hidden"/>
            <div
              className={this.state.dragStyleClass}
              onDragEnter={e => this.onDragEnter(e)}
              onDragLeave={e => this.onDragLeave(e)}
              onDragOver={e => e.preventDefault()}
              onDrop={e => this.onDrop(e)}
            >
              <div className='drop_text'>{this.props.env.translator('components.file_upload.drag_and_drop')}</div>
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
