import { withErrorBoundary } from 'shared/hoc';

modulejs.define('HBWFormUser', ['React', 'ReactDOM', 'HBWFormSelect'], (React, ReactDOM, Select) => {
  class HBWFormUser extends React.Component {
    componentDidMount () {
      this.props.onRef(this);
    }

    componentWillUnmount () {
      this.props.onRef(undefined);
    }

    render () {
      const {
        name, params, disabled, task, env
      } = this.props;

      const selectParams = {
        ...params,
        placeholder: params.placeholder || 'User',
        mode:        'lookup',
        url:         '/users/lookup',
        userLookup:  true,
        choices:     []
      };

      return <Select
        name={name}
        params={selectParams}
        task={task}
        env={env}
        disabled={disabled}
        onRef={(i) => { this[`${name}`] = i; }} />;
    }

    serialize = () => this[`${this.props.name}`].serialize();
  }

  return withErrorBoundary(HBWFormUser);
});
