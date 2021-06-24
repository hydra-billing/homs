import PropTypes from 'prop-types';
import cx from 'classnames';
import compose from 'shared/utils/compose';
import { withCallbacks, withConditions, withErrorBoundary } from 'shared/hoc';
import { v4 as uuidv4 } from 'uuid';

modulejs.define('HBWFormFileUpload', ['React'], (React) => {
  class HBWFormFileUpload extends React.Component {
    static propTypes = {
      name:   PropTypes.string.isRequired,
      params: PropTypes.shape({
        name:             PropTypes.string.isRequired,
        label:            PropTypes.string.isRequired,
        label_css:        PropTypes.string,
        css_class:        PropTypes.string,
        multiple:         PropTypes.bool,
        input_text:       PropTypes.string,
        browse_link_text: PropTypes.string,
        description:      PropTypes.shape({
          placement: PropTypes.oneOf(['top', 'bottom']),
          text:      PropTypes.string
        })
      }).isRequired,
      task: PropTypes.shape({
        key:         PropTypes.string.isRequired,
        process_key: PropTypes.string.isRequired
      }).isRequired,
      disabled:        PropTypes.bool.isRequired,
      hidden:          PropTypes.bool.isRequired,
      fileListPresent: PropTypes.bool.isRequired,
      env:             PropTypes.object.isRequired,
      onRef:           PropTypes.func.isRequired,
      trigger:         PropTypes.func.isRequired
    }

    state = {
      valid:                 true,
      files:                 [],
      unprocessedFilesCount: 0,
      isDragActive:          false
    };

    fileInputID = uuidv4();

    componentDidMount () {
      this.props.onRef(this);
    }

    componentWillUnmount () {
      this.props.onRef(undefined);
    }

    render () {
      const {
        name, params, hidden, fileListPresent, task, env
      } = this.props;

      const { files } = this.state;

      const hiddenValue = JSON.stringify({ files });
      const cssClass = cx('hbw-file-upload', params.css_class, { hidden });
      const errorMessage = env.translator('errors.file_list_field_required');
      const errorMessageCss = cx('alert', 'alert-danger', { hidden: fileListPresent });
      const label = env.bpTranslator(`${task.process_key}.${task.key}.${name}`, {}, params.label);
      const labelCSS = cx('hbw-file-upload-label', params.label_css);

      return (
        <div className={cssClass}>
          <span className={labelCSS}>{label}</span>
          <div className={errorMessageCss}>{errorMessage}</div>
          {files.length > 0 && this.renderPreviewRow()}
          <div className="form-group">
            {params.description?.placement === 'top' && this.renderDescription()}
            {this.renderFileInput()}
            <input name={name} value={hiddenValue} type="hidden"/>
            {params.description?.placement === 'bottom' && this.renderDescription()}
          </div>
        </div>
      );
    }

    renderFileInput = () => {
      const {
        env, name, params, disabled
      } = this.props;

      const { isDragActive } = this.state;

      const opts = {
        disabled,
        name,
        id:       this.fileInputID,
        onChange: this.onChange,
        multiple: params.multiple
      };

      const inputText = params.input_text || env.translator('components.file_upload.drag_and_drop');
      const browseLinkText = params.browse_link_text || env.translator('components.file_upload.browse');

      return (
        <div
          className={cx('attacher', { activated: isDragActive })}
          onDragEnter={e => this.onDragEnter(e)}
          onDragLeave={e => this.onDragLeave(e)}
          onDragOver={e => e.preventDefault()}
          onDrop={e => this.onDrop(e)}
        >
          <div className='drop-text'>
            <span className="fa fas fa-cloud-upload-alt"/>
            {inputText}
            <label htmlFor={this.fileInputID}>
              <a>{browseLinkText}</a>
            </label>
            <input {...opts} type="file" hidden/>
          </div>
        </div>
      );
    }

    renderPreviewRow = () => (
      <div className="files-preview-row">
        {this.state.files.map(file => this.renderPreviewItem(file))}
      </div>
    )

    renderPreviewItem = ({ name, type, fileURL }) => (
      <div className="files-preview-item" key={fileURL}>
        <div className="far fa-times-circle remove-file" onClick={() => this.removeFile(name)}/>
        <div className="files-preview-image">
          {this.renderPreviewImage(name, type, fileURL)}
        </div>
        <span className="files-preview-name" title={name}>{this.ellipsisFileName(name)}</span>
      </div>
    )

    renderPreviewImage = (name, type, fileURL) => {
      if (type.startsWith('image/')) {
        return <img src={fileURL} alt={name}/>;
      } else if (type === 'application/pdf') {
        return <embed src={fileURL} type={type}/>;
      } else {
        return <span className="far fa-file fa-7x"/>;
      }
    }

    renderDescription = () => {
      const { placement, text } = this.props.params.description;

      return <div className="description" data-test={`description-${placement}`}>{text}</div>;
    }

    ellipsisFileName = name => (
      name.length > 15
        ? `${name.slice(0, 9)}...${name.slice(-6)}`
        : name
    )

    onDragEnter = (event) => {
      event.preventDefault();
      this.setState({ isDragActive: true });
    };

    onDragLeave = (event) => {
      event.preventDefault();
      this.setState({ isDragActive: false });
    };

    onDrop = (event) => {
      event.preventDefault();
      const files = Array.from(event.dataTransfer.files);
      this.setState({ isDragActive: false });
      this.processFiles(files);
    };

    onChange = (event) => {
      const files = Array.from(event.target.files);
      this.processFiles(files);
    };

    setStateForMultipleFiles = (files) => {
      this.setState(
        { unprocessedFilesCount: files.length },
        () => files.forEach(file => this.processFile(file))
      );
    };

    setStateForSingleFile = (file) => {
      this.setState(
        {
          unprocessedFilesCount: 1,
          files:                 []
        },
        () => this.processFile(file)
      );
    };

    processFiles = (files) => {
      if (files.length === 0) return;

      this.props.trigger('hbw:file-upload-started');

      if (this.props.params.multiple) {
        this.setStateForMultipleFiles(files);
      } else {
        this.setStateForSingleFile(files[0]);
      }
    };

    addFile = (file) => {
      this.setState(({ files, unprocessedFilesCount }) => ({
        files:                 [...files, file],
        unprocessedFilesCount: unprocessedFilesCount - 1
      }),
      () => {
        if (this.state.unprocessedFilesCount === 0) {
          this.props.trigger('hbw:file-upload-finished');
        }
      });
    };

    removeFile = (name) => {
      this.setState(({ files }) => (
        { files: files.filter(file => file.name !== name) }
      ));
    }

    processFile = (file) => {
      const fileReader = new FileReader();

      fileReader.onloadend = () => {
        this.addFile({
          fieldName: this.props.params.name,
          name:      file.name,
          type:      file.type,
          fileURL:   URL.createObjectURL(file),
          content:   window.btoa(fileReader.result)
        });
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
