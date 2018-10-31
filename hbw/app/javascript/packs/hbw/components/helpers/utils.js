const getDisplayName = WrappedComponent => (WrappedComponent.displayName || WrappedComponent.name || 'Component');

const compose = (...args) => value => args.reduceRight((acc, func) => func(acc), value);

export { getDisplayName, compose };
