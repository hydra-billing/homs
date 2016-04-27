module Features
  module UsersHelper
    def table_lines
      page.find('table').all('tr').map do |row|
        row.all('td').map(&:text)
      end
    end

    def label_node(name)
      page.find("[for='#{name}']")
    end

    def button
      page.find('.btn.btn-primary')
    end

    def header3
      page.find('h3')
    end

    def node_by_label(name, tag)
      parent_node(label_node(name)).find(tag)
    end

    def input_by_label(name)
      node_by_label(name, 'input')
    end

    def select_by_label(name)
      node_by_label(name, 'select')
    end

    def validation_errors_container
      page.find('#error_explanation')
    end

    def is_input_in_error?(name)
      parent_node(label_node(name))['class'].include?('has-error')
    end

    def input_error_text(name)
      parent_node(label_node(name)).find('span').text
    end

    def link_by_href(href)
      page.find("a[href='#{href}']")
    end

    def user_edit(usr)
      link_by_href("/users/#{usr.id}/edit")
    end

    def user_generate_api_token(usr)
      link_by_href("/users/#{usr.id}/generate_api_token")
    end

    def user_clear_api_token(usr)
      link_by_href("/users/#{usr.id}/clear_api_token")
    end

    def user_data
      parent_node(header).all('div.row > div > p').map(&:text)
    end

    def is_button_red?(href)
      link_by_href(href)['class'].include?('btn-danger')
    end

    def active_modal_dialog
      page.find('#confirmation_dialog', visible: true)
    end

    def active_modal_dialog_cancel
      active_modal_dialog.find('.btn.cancel')
    end

    def active_modal_dialog_proceed
      active_modal_dialog.find('.btn.proceed')
    end

    def active_modal_dialog_body
      active_modal_dialog.find('.modal-body')
    end

    def active_modal_dialogs
      page.all('#confirmation_dialog', visible: true)
    end
  end
end
