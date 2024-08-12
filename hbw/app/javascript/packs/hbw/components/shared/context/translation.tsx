import React, {
  createContext, ComponentType, FC, useState, useEffect, useContext
} from 'react';
import TranslatorFactory from '../../../translator';
import { localizer } from '../../../init/date_localizer';
import ConnectionContext, { ContextType as ConnectionContextType } from './connection';

export type ContextType = {
  locale: {
    code: 'en' | 'ru' | 'es' | 'fr',
    dateTimeFormat: string
  }
  translate: (key: string, vars?: object, fallback?: string) => string,
  translateBP: (key: string, vars?: object, fallback?: string) => string,
  Localizer: {
    localizeDatetime: (str: string) => string | null,
    localizeDayMonth: (str: string) => string | null,
    localizeDayMonthYear:(str: string) => string | null
  }
}

const TranslationContext = createContext<ContextType | null>(null);

type InitParams = {
  locale: {
    code: 'en' | 'ru' | 'es' | 'fr',
    dateTimeFormat: string
  }
}

export const withTranslationContext = (
  { locale }: InitParams
) => (WrappedComponent: ComponentType) => {
  const TranslationProvider: FC = (props) => {
    const connection = useContext(ConnectionContext) as ConnectionContextType;

    const [BPTranslator, setBPTranslator] = useState({ t: () => '' });

    useEffect(() => {
      const fetchBPTranslations = async () => {
        const response = await connection.request({
          url:    `${connection.serverURL}/translations`,
          method: 'GET'
        });

        const BPTranslations = await response.json();

        setBPTranslator({ t: TranslatorFactory.getTranslatorForLocale(locale.code, BPTranslations) });
      };

      fetchBPTranslations();
    }, []);

    const translate = TranslatorFactory.getTranslatorForLocale(locale.code);
    const Localizer = localizer(locale);

    return (
      <TranslationContext.Provider value={{
        locale, translate, translateBP: BPTranslator.t, Localizer
      }}>
        <WrappedComponent {...props} />
      </TranslationContext.Provider>
    );
  };

  return TranslationProvider;
};

export default TranslationContext;
