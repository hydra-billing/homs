import cx from 'classnames';
import React, {
  useContext, useEffect, useRef, useState
} from 'react';
import { withCallbacks } from 'shared/hoc';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import ConnectionContext from 'shared/context/connection';
import TranslationContext from 'shared/context/translation';
import Pending from './pending';
import Error from './error';

modulejs.define(
  'HBWEntityTask',
  ['jQuery', 'HBWForm', 'HBWFormDefinition'],
  (jQuery, Form, FormDefinition) => {
    const HBWEntityTask = ({
      taskId, task, entityClassCode, guid, trigger, bind, collapsed: initiallyCollapsed
    }) => {
      const { request, serverURL } = useContext(ConnectionContext);
      const { translateBP } = useContext(TranslationContext);

      const [error, setError] = useState(null);
      const [collapsed, setCollapsed] = useState(initiallyCollapsed || false);

      const rootNode = useRef(null);

      const saveForm = variables => request({
        url:    `${serverURL}/tasks/${taskId}/form`,
        method: 'PUT',
        data:   {
          form_data:    variables,
          entity_class: entityClassCode,
          process_key:  task.process_key
        },
        headers: {
          'X-CSRF-Token': task.form.csrf_token,
          'Content-Type': 'application/json'
        }
      });

      const submitForm = (variables) => {
        saveForm(variables)
          .then(() => {
            setError(null);
            trigger('hbw:form-submitted', task);
          })
          .catch((response) => {
            setError(response);

            trigger('hbw:form-submitting-failed', {
              response,
              task
            });
          });
      };

      const choose = () => trigger('hbw:task-clicked', task);

      const toggleCollapse = () => setCollapsed(!collapsed);

      useEffect(() => {
        bind(`hbw:submit-form-${guid}`, submitForm);

        const $rootElement = jQuery(rootNode.current);
        $rootElement.on('hidden.bs.collapse', choose);
        $rootElement.on('shown.bs.collapse', choose);

        return () => {
          jQuery(rootNode.current)
            .off('hidden.bs.collapse')
            .off('shown.bs.collapse');
        };
      }, []);

      const formVariablesFromTask = () => {
        const { form } = task;

        const formVariables = {};
        const formDef = new FormDefinition(form);

        [...form.variables].forEach(({ name, value }) => {
          if (formDef.fieldExist(name)) {
            formVariables[name] = value;
          }
        });

        return formVariables;
      };

      const renderForm = () => {
        if (task.form !== undefined) {
          if (error) {
            return <Error error={error}/>;
          } else {
            const opts = {
              task,
              error,
              id:            guid,
              variables:     formVariablesFromTask(task),
              taskVariables: task.form.variables
            };

            return <Form {...opts}/>;
          }
        } else {
          return <div className="hbw-spinner"><Pending /></div>;
        }
      };

      const iconClass = collapsed ? 'chevron-down' : 'chevron-up';

      return <div className="panel panel-default" ref={rootNode}>
          <div className="panel-heading">
            <h4 className="panel-title collapsable">
              <a onClick={toggleCollapse}>
                {translateBP(`${task.process_key}.${task.key}.label`, {}, task.name)}
              </a>
              <FontAwesomeIcon
                onClick={toggleCollapse}
                className={cx('indicator', 'pull-right')}
                icon={iconClass}
              />
            </h4>
          </div>
          {!collapsed && (
            <div className="panel-body">
              {renderForm()}
            </div>
          )}
        </div>;
    };

    return withCallbacks(HBWEntityTask);
  }
);
