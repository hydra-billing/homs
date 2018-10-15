/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
modulejs.define('HBWFormFileUpload',
  ['React', 'jQuery', 'HBWDeleteIfMixin', 'HBWCallbacksMixin'],
  (React, jQuery, DeleteIfMixin, CallbacksMixin) => React.createClass({
    mixins: [DeleteIfMixin, CallbacksMixin],

    getInitialState () {
      return {
        valid:      true,
        files:      [],
        filesCount: 0
      };
    },

    render () {
      const opts = {
        name:     this.props.params.name,
        onChange: this.onChange
      };

      const hiddenValue = JSON.stringify({ files: this.state.files });

      let cssClass = this.props.params.css_class;
      if (this.hidden) {
        cssClass += ' hidden';
      }

      const { label } = this.props.params;
      const labelCss = this.props.params.label_css;

      return <div className={cssClass}>
        <span className={labelCss}>{label}</span>
        <div className="form-group">
          <input {...opts} type="file" multiple></input>
          <input name={this.props.params.name} value={hiddenValue} type="hidden"/>
        </div>
      </div>;
    },

    onChange (event) {
      const $el = event.target;
      const files = Array.from($el.files);

      this.setState({
        files:      [],
        filesCount: files.length
      });

      if (files.length > 0) {
        this.trigger('hbw:file-upload-started');

        return files.map(file => this.readFiles(file.name, file));
      }
    },

    addValue (name, res) {
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
        this.trigger('hbw:file-upload-finished');
      }
    },

    readFiles (name, file) {
      const fileReader = new FileReader();

      fileReader.onloadend = () => {
        this.addValue(name, fileReader.result);
      };

      return fileReader.readAsBinaryString(file);
    }
  }));
