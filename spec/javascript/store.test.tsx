import React from 'react';
import { shallow, ShallowWrapper } from 'enzyme';
// @ts-ignore
import { withStoreContext } from 'hbw/components/shared/context/store';
// @ts-ignore
import Dispatcher from 'hbw/dispatcher';

type TaskEvent = {
  task_id: string,
  event_name: string,
  version: number,
  cache_key?: string | null,
  assigned_to_me: boolean
}

let emitEvent: (event: TaskEvent) => void;

const mockConsumer = {
  subscriptions: {
    create: (
      _: object,
      { received }: { received: (data: string) => void }
    ) => {
      emitEvent = async (event: TaskEvent) => received(JSON.stringify(event));
    }
  }
};

jest.mock('actioncable', () => ({ createConsumer: () => mockConsumer }));

const serverURL = 'http://mockURL:3000';
const userIdentifier = 'user@example.com';
const entityClassCode = 'order';
const unassignedTask = { id: 'unassignedTaskID', assignee: null };
const assignedTask = { id: 'assignedTaskID', assignee: 'user@example.com' };
const longFetchedTask = { id: 'longFetchedTask', assignee: 'user@example.com' };

const mockRequest = ({ url }: { url: string }) => ({
  json: async () => {
    switch (url) {
      case `${serverURL}/tasks/${unassignedTask.id}`:
        return unassignedTask;
      case `${serverURL}/tasks/${assignedTask.id}`:
        return assignedTask;
      case `${serverURL}/tasks/${longFetchedTask.id}`:
        await new Promise(_ => setTimeout(_, 50));
        return longFetchedTask;
      default:
        return [];
    }
  }
});

const mockConnection = {
  request: mockRequest,
  serverURL
};

const events = {
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

const initialState = {
  tasks:      [],
  events:     [],
  versions:   {},
  fetching:   false,
  socket:     mockConsumer,
  ready:      true,
  error:      null,
  activeTask: null
};

describe('<StoreProvider />', () => {
  let shallowStore: ShallowWrapper;

  beforeEach(() => {
    const StoreProvider = withStoreContext({
      userIdentifier,
      entityClassCode,
      widgetURL:         serverURL,
      showNotifications: false,
      dispatcher:        new Dispatcher(),
      connection:        mockConnection
    })(() => <></>);

    shallowStore = shallow(<StoreProvider />);
  });

  it('initializes', async () => {
    expect(shallowStore.state()).toEqual(initialState);
  });

  it.each([
    { event: events.create, task: unassignedTask },
    { event: events.assignment, task: assignedTask }
  ])('adds task to state on $event.event_name', async ({ event, task }) => {
    await emitEvent(event);

    expect(shallowStore.state()).toEqual({
      ...initialState,
      tasks:    [task],
      versions: { [task.id]: event.version }
    });
  });

  it.each([
    { event: events.complete },
    { event: events.delete }
  ])('removes task from state on $event.event_name', async ({ event }) => {
    const task = assignedTask;

    shallowStore.setState({
      tasks:    [assignedTask],
      versions: { [assignedTask.id]: event.version - 1 }
    });

    await emitEvent(event);

    expect(shallowStore.state()).toEqual({
      ...initialState,
      versions: { [task.id]: event.version }
    });
  });

  it('ignores task assigned to someone else', async () => {
    const { assignment: event } = events;
    const task = assignedTask;

    await emitEvent({ ...event, assigned_to_me: false });

    expect(shallowStore.state()).toEqual({
      ...initialState,
      versions: { [task.id]: event.version }
    });
  });

  it('ignores event with outdated version', async () => {
    const task = longFetchedTask;
    const longCreateEvent = { ...events.create, task_id: task.id };
    const completeEvent = { ...events.complete, task_id: task.id };

    await Promise.all([
      emitEvent(longCreateEvent),
      emitEvent(completeEvent)
    ]);

    expect(shallowStore.state()).toEqual({
      ...initialState,
      versions: { [task.id]: completeEvent.version }
    });
  });
});
