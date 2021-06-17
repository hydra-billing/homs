import { configure } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

global.window = window;
global.$ = require('jquery');
global.jQuery = require('jquery');
global.jquery = require('jquery');

configure({ adapter: new Adapter() });
