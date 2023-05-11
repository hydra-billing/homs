import React from 'react';
import renderer from 'react-test-renderer';
import Priority from 'hbw/components/shared/element/priority';
import { withTranslationContext } from 'hbw/components/shared/context/translation';
import { withConnectionContext } from 'hbw/components/shared/context/connection';
import { waitFor } from '@testing-library/react';
import compose from 'shared/utils/compose';
import ConnectionMock from './helpers/mock_connection';

describe('Priority label should be rendered properly', () => {
  const PriorityWithContext = compose(
    withConnectionContext({ connection: ConnectionMock }),
    withTranslationContext({ locale: { code: 'en' } })
  )(Priority);

  const priorityComponent = priority => (
    renderer
      .create(<PriorityWithContext priority={priority} />)
      .toJSON()
  );

  const matchSnapshot = priorityName => priorityValue => (
    it(`for priority ${priorityValue} renders '${priorityName}'`, async () => {
      await waitFor(() => {
        expect(priorityComponent(priorityValue)).toMatchSnapshot();
      });
    })
  );

  matchSnapshot('Medium')(-50);
  matchSnapshot('Medium')(0);
  matchSnapshot('Medium')(49.9);
  matchSnapshot('High')(50);
  matchSnapshot('High')(62);
  matchSnapshot('High')(74.9);
  matchSnapshot('Urgent')(75);
  matchSnapshot('Urgent')(123456);
});
