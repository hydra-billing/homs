import React, { useContext, useState } from 'react';
import Messenger from 'messenger';
import StoreContext from 'shared/context/store';
import ConnectionContext from 'shared/context/connection';
import Tabs from 'shared/element/task_tabs';
import Search from './search';
import Table from './table';
import Overview from './task_overview';
import TranslationContext from '../shared/context/translation';

const HBWClaimingTaskList = () => {
  const perPage = 50;
  const tabs = {
    my:         0,
    unassigned: 1,
  };

  const { request, serverURL } = useContext(ConnectionContext);
  const { translate: t } = useContext(TranslationContext);
  const {
    myTasks, unassignedTasks, closeTask, fetching, count, openTask, activeTask
  } = useContext(StoreContext);

  const [tab, setTab] = useState(tabs.my);
  const [page, setPage] = useState(1);
  const [lastPage, setLastPage] = useState(false);
  const [claimingTask, setClaimingTask] = useState(null);
  const [query, setQuery] = useState('');
  const [searchQuery, setSearchQuery] = useState(null);

  const isMyTab = () => tab === tabs.my;

  const tasksForCurrentTab = () => (isMyTab() ? myTasks : unassignedTasks);

  const addPage = () => {
    const currentPage = page;

    setPage(currentPage + 1);
    setLastPage(tasksForCurrentTab().length <= (currentPage + 1) * perPage);
  };

  const claim = async (task) => {
    setClaimingTask(task);

    const { ok } = await request({
      url:    `${serverURL}/tasks/${task.id}/claim`,
      method: 'POST'
    });

    if (!ok) {
      Messenger.error(t('errors.task_already_claimed', {
        task_name: task.name
      }));
    }

    closeTask(task.id);

    setClaimingTask(null);
  };

  const onSearch = ({ target }) => {
    const { value } = target;

    setQuery(value);

    if (value.length > 2) {
      setSearchQuery(value.trim());
    } else {
      setSearchQuery(null);
    }
  };

  const clearSearch = () => {
    setQuery('');
    setSearchQuery(null);
  };

  const switchTabTo = (to) => {
    if (to !== tab) {
      setTab(to);
      closeTask();
      clearSearch();
    }
  };

  const filterTasks = () => tasksForCurrentTab().filter(({ description }) => (
    description && description.toLowerCase().includes(searchQuery.toLowerCase())
  ));

  const tasksForRender = () => {
    const filteredTasks = searchQuery
      ? filterTasks()
      : tasksForCurrentTab();

    return filteredTasks.slice(0, perPage * page);
  };

  return (
      <div id="hbw-claiming-tasks">
        <div className="table">
          <div className="title-row">
            <div className="title">
              {t('components.claiming.open_tasks')}
            </div>
             <Search query={query}
                     search={onSearch}
                     clear={clearSearch}
             />
          </div>
          <Tabs count={count}
                tabs={tabs}
                activeTab={tab}
                onTabChange={switchTabTo}
          >
            <Table tasks={tasksForRender()}
                   fetching={fetching}
                   addPage={addPage}
                   openTask={openTask}
                   lastPage={lastPage}
                   showClaimButton={!isMyTab()}
                   claimingTask={claimingTask}
                   claim={claim}
                   activeTask={activeTask}
            />
          </Tabs>
        </div>
         <div className="overview">
          {activeTask && (
            <Overview entityUrl={activeTask.entity_url}
                      assigned={isMyTab()}
                      task={activeTask}
                      claim={claim}
            />
          )}
         </div>
      </div>
  );
};

export default HBWClaimingTaskList;
