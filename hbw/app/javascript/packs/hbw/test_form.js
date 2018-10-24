modulejs.define('HBWTestForm', [], () => {
  class TestForm {
    constructor () {
      this.with_all_controls = {
        name:        'Тестовая форма',
        description: ['Это форма для тестирования рендеринга всех видов контролов', 'Пожалуйста, дочитайте это многострочное пояснение до конца', 'Возможно, это поможет вам сделать меньше ошибок'],
        css_class:   'col-xs-12 col-sm-6 col-md-5 col-lg-4',
        fields:      [
          {
            name:      'note1',
            type:      'note',
            html:      '<H1>Внимание!</H1>Это форма для тестирования рендеринга всех видов контролов<br/>Пожалуйста, дочитайте это многострочное пояснение до конца<br/>Возможно, это поможет вам сделать меньше ошибок',
            css_class: 'col-xs-12'
          },
          {
            name:      'group1',
            type:      'group', // Тип поля формы
            label:     'Общие данные',
            tooltip:   'Какое-то пояснение',
            css_class: 'col-xs-12',
            fields:    [
              {
                name:      'lastName',
                type:      'string',
                tooltip:   'Фамилия клиента',
                label:     'Фамилия',
                label_css: '',
                css_class: 'col-xs-6 col-sm-4 col-md-3',
                editable:  false
              },
              {
                name:      'firstName',
                type:      'string',
                tooltip:   'Имя клиента',
                label:     'Имя',
                label_css: '',
                css_class: 'col-xs-6 col-sm-4 col-md-3'
              },
              {
                name:      'parentName',
                type:      'string',
                tooltip:   'Отчество клиента',
                label:     'Отчество',
                label_css: '',
                css_class: 'col-xs-6 col-sm-4 col-md-3'
              },
              {
                name:      'phone',
                type:      'string',
                tooltip:   'Контактный телефон клиента',
                label:     'Телефон',
                label_css: '',
                css_class: 'col-xs-6 col-sm-4 col-md-3',
                pattern:   '+7 ({{999}}) {{999}}-{{99}}-{{99}}'
              },
              {
                name:      'buildingAddress',
                type:      'string',
                tooltip:   'Адрес дома',
                label:     'Адрес дома',
                label_css: '',
                css_class: 'col-xs-6 col-sm-6 col-md-5'
              },
              {
                name:      'flatNo',
                type:      'string',
                tooltip:   'Номер квартиры',
                label:     'Кв.',
                label_css: '',
                css_class: 'col-xs-2 col-sm-2 col-md-1 col-lg-1'
              },
              {
                name:      'wingNo',
                type:      'string',
                tooltip:   'Номер подъезда',
                label:     'под.',
                label_css: '',
                css_class: 'col-xs-2 col-sm-2 col-md-1 col-lg-1'
              },
              {
                name:      'floorNo',
                type:      'string',
                tooltip:   'Номер этажа',
                label:     'эт.',
                label_css: '',
                css_class: 'col-xs-2 col-sm-2 col-md-1 col-lg-1'
              },
              {
                name:      'comment',
                type:      'text',
                rows:      3,
                tooltip:   'Комментарий к заказу',
                label:     'Комментарий',
                label_css: '',
                css_class: 'col-xs-12',
                editable:  false
              }
            ]
          },
          {
            name:      'group2',
            type:      'group',
            label:     'Паспортные данные',
            tooltip:   'Какое-то пояснение',
            css_class: 'col-xs-12',
            fields:    [
              {
                name:      'docType',
                type:      'list',
                css_class: 'col-xs-4 col-sm-5 col-md-3',
                tooltip:   'Тип удостоверяющего документа',
                label:     'Документ',
                label_css: '',
                choices:   ['паспорт', 'вод.удостоверение', 'загран.паспорт']
              },
              {
                name:      'passportSerie',
                type:      'string',
                tooltip:   'Серия паспорта',
                label:     'Серия',
                label_css: '',
                css_class: 'col-xs-3 col-sm-2 col-md-2',
                pattern:   '{{99}} {{99}}'
              },
              {
                name:      'passportNo',
                type:      'string',
                tooltip:   'Номер паспорта',
                label:     'Номер',
                label_css: '',
                css_class: 'col-xs-5 col-sm-3 col-md-2',
                pattern:   '{{999}} {{999}}'
              },
              {
                name:      'passportIssuerDept',
                type:      'string',
                tooltip:   'Код подразделения',
                label:     'Подр.',
                label_css: '',
                css_class: 'col-xs-3 col-sm-2 col-md-2',
                pattern:   '{{999}}-{{999}}'
              },
              {
                name:      'passportIssueDate',
                type:      'datetime',
                tooltip:   'Дата выдачи паспорта',
                label:     'Дата',
                label_css: '',
                css_class: 'col-xs-4 col-sm-3 col-md-3',
                format:    'DD.MM.YYYY'
              },
              {
                name:      'passportIssuer',
                type:      'string',
                tooltip:   'Паспорт выдан',
                label:     'Выдан',
                label_css: '',
                css_class: 'col-xs-12 col-sm-9 col-md-12'
              },
              {
                name:      'passportValid',
                type:      'checkbox',
                tooltip:   'Паспорт действителен',
                label:     'Действителен',
                label_css: '',
                css_class: 'col-xs-12 col-sm-9 col-md-12'
              }
            ]
          },
          {
            name:      'group3',
            type:      'group',
            label:     'Входной опрос',
            tooltip:   'Какое-то пояснение',
            css_class: 'col-xs-12',
            fields:    [
              {
                name:      'someEvent',
                type:      'datetime',
                tooltip:   'Дата со временем для проверки схлопывания формы',
                label:     'Дата и время',
                label_css: '',
                css_class: 'col-xs-4 col-sm-3 col-md-3',
                format:    'DD.MM.YYYY HH:MM'
              },
              {
                name:      'marketingChannel',
                type:      'list',
                css_class: 'col-xs-12 col-sm-6 col-md-4',
                tooltip:   'Откуда вы о нас узнали?',
                label:     'Маркетинговый канал',
                label_css: '',
                choices:   ['рекомендация друзей/знакомых', 'поиск/реклама в интернете', 'реклама в печатных изданиях', 'реклама на улице', 'листовки', 'не помню', 'другое']
              }
            ]
          },
          {
            name:      'currentProvider',
            type:      'submit_select',
            css_class: 'col-xs-12',
            options:   [
              {
                name:      'Не пользовался',
                value:     'Не пользовался',
                css_class: 'btn btn-primary'
              },
              {
                name:      'Offline Telecom',
                value:     'Offline Telecom',
                css_class: 'btn btn-warning'
              },
              {
                name:      'Goodlife',
                value:     'Goodlife',
                css_class: 'btn btn-primary'
              },
              {
                name:      'ОчХорИнтернет',
                value:     'ОчХорИнтернет',
                css_class: 'btn btn-warning'
              },
              {
                name:      'Вектор',
                value:     'Вектор',
                css_class: 'btn btn-primary'
              },
              {
                name:      'Азимут',
                value:     'Азимут',
                css_class: 'btn btn-warning'
              },
              {
                name:      'Другое',
                value:     'Другое',
                css_class: 'btn btn-primary'
              },
            ]
          }
        ]
      };
    }
  }

  return TestForm;
});
