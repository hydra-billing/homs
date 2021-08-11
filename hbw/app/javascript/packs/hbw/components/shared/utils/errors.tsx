export type WidgetErrorType = {
  header: string,
  body?: string,
  notificationText?: string
  level: 'alert' | 'warn' | 'error'
}

export const CamundaError: WidgetErrorType = {
  header:           'errors.camunda_is_unavailable',
  notificationText: 'errors.camunda_is_unavailable',
  level:            'error',
};
