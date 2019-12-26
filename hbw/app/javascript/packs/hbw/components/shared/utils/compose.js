export default (...args) => value => args.reduceRight((acc, func) => func(acc), value);
