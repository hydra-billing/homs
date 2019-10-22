module Features
  module WaitForAjaxHelper
    def wait_for_ajax
      Timeout.timeout(Capybara.default_max_wait_time) do
        loop until finished_all_ajax_requests?
      end
    end

    def finished_all_ajax_requests?
      result = page.evaluate_script('jQuery.active')
      result.nil? || result.zero?
    end

    def ajax
      tick
      yield
      tick
    ensure
      wait_for_ajax
    end

    def tick
      sleep(Capybara.default_max_wait_time / 2)
    end
  end
end
