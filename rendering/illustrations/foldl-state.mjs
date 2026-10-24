export function foldlStates(values) {
  if (!Array.isArray(values) || values.some(value => typeof value !== 'string' || !/^[1-9]$/.test(value)) ||
      new Set(values).size !== values.length || values.length > 3) {
    throw new Error('This trial supports at most three distinct single-digit elements.');
  }
  const states = [];
  let accumulator = 'z';
  let expression = 'z';
  for (let index = 0; index <= values.length; index += 1) {
    states.push({ accumulator, expression, remaining: values.slice(index) });
    if (index < values.length) {
      accumulator = { function: 'f', left: accumulator, right: values[index] };
      expression = `f ${index === 0 ? expression : `(${expression})`} ${values[index]}`;
    }
  }
  return states;
}
