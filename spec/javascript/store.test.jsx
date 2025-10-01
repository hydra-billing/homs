import React, { useContext } from 'react';
import StoreContext, { withStoreContext } from 'hbw/components/shared/context/store';
import Dispatcher from 'hbw/dispatcher';
import { withTranslationContext } from 'hbw/components/shared/context/translation';
import { withDispatcherContext } from 'hbw/components/shared/context/dispatcher';
import compose from 'shared/utils/compose';
import { stringify } from 'qs';
import { withConnectionContext } from 'hbw/components/shared/context/connection';
import { render, waitFor, cleanup, act } from '@testing-library/react';

const dispatcher = new Dispatcher();
let emitEvent;
const mockConsumer = {
  subscriptions: {
    create: (
      _,
      received
    ) => {
      emitEvent = async (event) => {
        await act(async () => {
          await received.received(JSON.stringify(event));
        });
      };
    }
  }
};

jest.mock('@rails/actioncable', () => ({ createConsumer: () => mockConsumer }));

const serverURL = 'http://mockURL:3000';
const userIdentifier = 'user@example.com';
const entityClassCode = 'order';
const unassignedTask = { id: 'unassignedTaskID', assignee: null };
const assignedTask = { id: 'assignedTaskID', assignee: 'user@example.com' };
const longFetchedTask = { id: 'longFetchedTask', assignee: 'user@example.com' };

const mockRequest = reqParams => ({
  json: async () => {
    switch (reqParams.url) {
      case `${serverURL}/tasks/${unassignedTask.id}`:
        return unassignedTask;
      case `${serverURL}/tasks/${assignedTask.id}`:
        return assignedTask;
      case `${serverURL}/tasks/${longFetchedTask.id}`:
        await new Promise(_ => setTimeout(_, 50));
        return longFetchedTask;
      case `${serverURL}/translations`:
        return {};
      default:
        return [];
    }
  }
});

const mockConnection = {
  request: mockRequest,
  serverURL
};

const testEvents = {
  create: {
    task_id:        unassignedTask.id,
    event_name:     'create',
    version:        1,
    cache_key:      null,
    assigned_to_me: false
  },
  assignment: {
    task_id:        assignedTask.id,
    event_name:     'assignment',
    version:        2,
    cache_key:      null,
    assigned_to_me: true
  },
  complete: {
    task_id:        assignedTask.id,
    event_name:     'complete',
    version:        3,
    assigned_to_me: true
  },
  delete: {
    task_id:        assignedTask.id,
    event_name:     'delete',
    version:        4,
    assigned_to_me: true
  }
};

describe('<StoreProvider />', () => {
  const TestingComponent = () => {
    const {
      tasks, events, versions, fetching, ready, activeTask
    } = useContext(StoreContext);

    return (
      <div>
        <p className="tasks">{stringify(tasks)}</p>
        <p className="events">{stringify(events)}</p>
        <p className="versions">{stringify(versions)}</p>
        <p className="fetching">{fetching.toString()}</p>
        <p className="ready">{ready.toString()}</p>
        <p className="activeTask">{stringify(activeTask)}</p>
      </div>
    );
  };

  const withContext = compose(
    withDispatcherContext({ dispatcher }),
    withConnectionContext({ connection: mockConnection }),
    withTranslationContext({ locale: { code: 'en' } }),
    withStoreContext({
      userIdentifier,
      entityClassCode,
      widgetURL:         serverURL,
      showNotifications: false,
      dispatcher,
      connection:        mockConnection
    })
  );

  let rendered;

  beforeEach(async () => {
    const Provider = withContext(TestingComponent);

    await waitFor(() => {
      rendered = render(<Provider />);
    });
  });

  afterEach(() => {
    cleanup();
  });

  it('initializes', async () => {
    await waitFor(() => {
      expect(rendered.container).toMatchSnapshot();
    });
  });

  it('adds task to state on create', async () => {
    await emitEvent(testEvents.create);

    await waitFor(() => {
      expect(rendered.container).toMatchSnapshot();
    });
  });

  it('adds task to state on assign', async () => {
    await emitEvent(testEvents.assignment);

    await waitFor(() => {
      expect(rendered.container).toMatchSnapshot();
    });
  });

  it('removes task from state on complete', async () => {
    await emitEvent(testEvents.assignment);
    await emitEvent(testEvents.complete);

    await waitFor(() => {
      expect(rendered.container).toMatchSnapshot();
    });
  });

  it('removes task from state on delete', async () => {
    await emitEvent(testEvents.assignment);
    await emitEvent(testEvents.delete);

    await waitFor(() => {
      expect(rendered.container).toMatchSnapshot();
    });
  });

  it('ignores task assigned to someone else', async () => {
    await emitEvent({ ...testEvents.assignment, assigned_to_me: false });

    await waitFor(() => {
      expect(rendered.container).toMatchSnapshot();
    });
  });

  it('ignores event with outdated version', async () => {
    const task = longFetchedTask;
    const longCreateEvent = { ...testEvents.create, task_id: task.id };
    const completeEvent = { ...testEvents.complete, task_id: task.id };
    await emitEvent(longCreateEvent);
    await emitEvent(completeEvent);

    await waitFor(() => {
      expect(rendered.container).toMatchSnapshot();
    });
  });
});
