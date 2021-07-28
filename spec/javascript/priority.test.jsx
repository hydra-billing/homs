import React from 'react';
import { shallow } from 'enzyme';
import Priority from 'hbw/components/shared/element/priority';
import { withTranslationContext } from 'hbw/components/shared/context/translation';

describe('Priority label should be rendered properly', () => {
  const PriorityWithContext = withTranslationContext({ locale: { code: 'en' } })(Priority);

  const shallowComponent = priority => shallow(
    <PriorityWithContext priority={priority} />
  );

  const itBehavesLike = priorityName => priorityValue => (
    it(`for priority ${priorityValue} renders '${priorityName}'`, () => {
      expect(shallowComponent(priorityValue).html()).toEqual(
        `<span class="badge priority ${priorityName.toLowerCase()}">${priorityName}</span>`
      );
    })
  );

  itBehavesLike('Medium')(-50);
  itBehavesLike('Medium')(0);
  itBehavesLike('Medium')(49.9);
  itBehavesLike('High')(50);
  itBehavesLike('High')(62);
  itBehavesLike('High')(74.9);
  itBehavesLike('Urgent')(75);
  itBehavesLike('Urgent')(123456);
});
