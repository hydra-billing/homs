require './hbw/lib/const'

module HBW
  module Fields
    class ServicesTable < Ordinary
      include HBW::Logger

      self.default_data_type = :json

      class_attribute :get_db_value_sql

      def value
        if variables_hash[name.to_sym].present? && variables_hash[name.to_sym].length.positive?
          return value.as_json
        end

        get_db_value
      end

      self.get_db_value_sql = "
        WITH SUBSCRIPTIONS AS (
          SELECT N_SUBSCRIPTION_ID,
                 N_PAR_SUBSCRIPTION_ID,
                 N_DOC_ID,
                 N_SERVICE_ID,
                 VC_SERVICE,
                 N_OBJECT_ID,
                 N_QUANT,
                 VC_UNIT,
                 D_BEGIN,
                 D_END,
                 N_CL_CREATING_STATE_ID,
                 SI_OBJECTS_PKG_S.GET_N_GOOD_ID(N_OBJECT_ID)          N_OBJECT_GOOD_ID,
                 SI_OBJECTS_PKG_S.GET_MAIN_N_OBJECT_ID(N_OBJECT_ID)   N_MAIN_OBJECT_ID
          FROM   SI_V_SUBSCRIPTIONS
          WHERE  N_ACCOUNT_ID       = %{account_id}
          AND    N_DOC_ID           = %{contract_id}
          AND    C_FL_CLOSED        = 'N'
          AND    N_SERVICE_TYPE_ID != SYS_CONTEXT('CONST', 'SERV_TYPE_Access')
          AND    ROWNUM > 0)
        SELECT S.N_SUBSCRIPTION_ID                                                   \"subscriptionId\",
               S.N_PAR_SUBSCRIPTION_ID                                               \"parSubscriptionId\",
               S.N_SERVICE_ID                                                        \"serviceId\",
               S.VC_SERVICE                                                          \"serviceName\",
               S.N_OBJECT_ID                                                         \"equipmentId\",
               SR_GOODS_PKG_S.GET_CODE_BY_ID(S.N_OBJECT_GOOD_ID)                     \"equipmentName\",
               SVPOC.N_PRICE                                                         \"servicePrice\",
               S.N_QUANT                                                             \"serviceQuantity\",
               S.VC_UNIT                                                             \"serviceUnit\",
               SVPOC.N_PRICE * NVL(S.N_QUANT, 1)                                     \"serviceTotalPrice\",
               S.D_BEGIN                                                             \"subscriptionBeginDate\",
               S.D_END                                                               \"subscriptionEndDate\",
               S.N_CL_CREATING_STATE_ID                                              \"allowProvisioning\",
               CASE
                 WHEN SERVICE_ADDRESS.N_REGION_ID IS NOT NULL
                   THEN SERVICE_ADDRESS.VC_VISUAL_CODE
                 ELSE SERVICE_ADDRESS.VC_NAME
               END                                                                   \"serviceAddress\",
               (SELECT VC_CODE
                FROM (
                  SELECT MAC_ADDRESS.VC_CODE
                  FROM   SI_V_OBJ_OBJECTS     SVOO
                  INNER JOIN SI_V_OBJECTS     SVO
                  ON SVO.N_OBJECT_ID = SVOO.N_BIND_OBJECT_ID
                  INNER JOIN SI_V_OBJ_ADDRESSES_SIMPLE     MAC_ADDRESS
                  ON  MAC_ADDRESS.N_OBJECT_ID        = SVOO.N_BIND_OBJECT_ID
                  AND MAC_ADDRESS.N_ADDR_TYPE_ID     = SYS_CONTEXT('CONST', 'ADDR_TYPE_MAC')
                  AND MAC_ADDRESS.N_OBJ_ADDR_TYPE_ID = SYS_CONTEXT('CONST', 'BIND_ADDR_TYPE_Actual')
                  AND MAC_ADDRESS.C_FL_ACTUAL        = 'Y'
                  AND MAC_ADDRESS.C_FL_MAIN          = 'Y'
                  WHERE SVOO.N_OBJECT_ID = S.N_OBJECT_ID
                  ORDER BY SVO.VC_CODE ASC)
                WHERE ROWNUM = 1)                                                    \"macAddress\",
                (SELECT VC_CODE
                 FROM (
                   SELECT IP_ADDRESS.VC_CODE
                   FROM   SI_V_OBJ_OBJECTS     SVOO
                   INNER JOIN SI_V_OBJECTS     SVO
                   ON SVO.N_OBJECT_ID = SVOO.N_BIND_OBJECT_ID
                   INNER JOIN SI_V_OBJ_ADDRESSES_SIMPLE     IP_ADDRESS
                   ON  IP_ADDRESS.N_OBJECT_ID        = SVOO.N_BIND_OBJECT_ID
                   AND IP_ADDRESS.N_ADDR_TYPE_ID     = SYS_CONTEXT('CONST', 'ADDR_TYPE_IP')
                   AND IP_ADDRESS.N_OBJ_ADDR_TYPE_ID = SYS_CONTEXT('CONST', 'BIND_ADDR_TYPE_Actual')
                   AND IP_ADDRESS.C_FL_ACTUAL        = 'Y'
                   AND IP_ADDRESS.C_FL_MAIN          = 'Y'
                   WHERE SVOO.N_OBJECT_ID = S.N_OBJECT_ID
                   ORDER BY SVO.VC_CODE ASC)
                 WHERE ROWNUM = 1)                                                   \"ipAddress\",
                (SELECT VC_CODE
                 FROM (
                   SELECT VLAN.VC_CODE
                   FROM   SI_V_OBJ_OBJECTS     SVOO
                   INNER JOIN SI_V_OBJECTS     SVO
                   ON SVO.N_OBJECT_ID = SVOO.N_BIND_OBJECT_ID
                   INNER JOIN SI_V_OBJ_ADDRESSES_SIMPLE     VLAN
                   ON  VLAN.N_OBJECT_ID        = SVOO.N_BIND_OBJECT_ID
                   AND VLAN.N_ADDR_TYPE_ID     = SYS_CONTEXT('CONST', 'ADDR_TYPE_VLAN')
                   AND VLAN.N_OBJ_ADDR_TYPE_ID = SYS_CONTEXT('CONST', 'BIND_ADDR_TYPE_Actual')
                   AND VLAN.C_FL_ACTUAL        = 'Y'
                   AND VLAN.C_FL_MAIN          = 'Y'
                   WHERE SVOO.N_OBJECT_ID = S.N_OBJECT_ID
                   ORDER BY SVO.VC_CODE ASC)
                 WHERE ROWNUM = 1)                                                   \"vlan\",
                (SELECT VC_CODE
                 FROM (
                   SELECT PHONE_NUMBER.VC_CODE
                   FROM SI_V_OBJ_OBJECTS     SVOO
                   INNER JOIN SI_V_OBJECTS     SVO
                   ON SVO.N_OBJECT_ID = SVOO.N_BIND_OBJECT_ID
                   INNER JOIN SI_V_OBJ_ADDRESSES_SIMPLE     PHONE_NUMBER
                   ON  PHONE_NUMBER.N_OBJECT_ID        = SVOO.N_BIND_OBJECT_ID
                   AND PHONE_NUMBER.N_ADDR_TYPE_ID     = SYS_CONTEXT('CONST', 'ADDR_TYPE_PhoneNumber')
                   AND PHONE_NUMBER.N_OBJ_ADDR_TYPE_ID = SYS_CONTEXT('CONST', 'BIND_ADDR_TYPE_Actual')
                   AND PHONE_NUMBER.C_FL_ACTUAL        = 'Y'
                   AND PHONE_NUMBER.C_FL_MAIN          = 'Y'
                   WHERE SVOO.N_OBJECT_ID = S.N_OBJECT_ID
                   ORDER BY SVO.VC_CODE ASC)
                 WHERE ROWNUM = 1)                                                   \"phone\"
        FROM   SUBSCRIPTIONS S
        INNER JOIN TABLE(
          SD_PRICE_ORDERS_PKG_S.GET_ORDERS_FOR_CONTRACT(
            num_N_CONTRACT_ID => S.N_DOC_ID))     CPO
        ON CPO.N_CONTRACT_ID = S.N_DOC_ID
        INNER JOIN SD_V_PRICE_ORDERS_C     SVPOC
        ON  SVPOC.N_DOC_ID  = CPO.N_PRICE_ORDER_ID
        AND SVPOC.N_GOOD_ID = S.N_SERVICE_ID
        LEFT OUTER JOIN SI_V_OBJ_ADDRESSES     SERVICE_ADDRESS
        ON  SERVICE_ADDRESS.N_OBJECT_ID        = S.N_MAIN_OBJECT_ID
        AND SERVICE_ADDRESS.N_ADDR_TYPE_ID     = SYS_CONTEXT('CONST', 'ADDR_TYPE_FactPlace')
        AND SERVICE_ADDRESS.N_OBJ_ADDR_TYPE_ID = SYS_CONTEXT('CONST', 'BIND_ADDR_TYPE_Serv')
        AND SERVICE_ADDRESS.N_ADDR_STATE_ID    = SYS_CONTEXT('CONST', 'ADDR_STATE_On')
        AND (SERVICE_ADDRESS.D_END IS NULL
          OR SERVICE_ADDRESS.D_END > SYSDATE)
        AND SERVICE_ADDRESS.C_FL_MAIN          = 'Y'
        AND SERVICE_ADDRESS.C_FL_ACTUAL        = 'Y'
        WHERE S.N_OBJECT_GOOD_ID IN (%{equipment_types})
        ORDER BY S.N_PAR_SUBSCRIPTION_ID DESC, S.D_BEGIN ASC
      "

      def get_db_value
        sql = get_db_value_sql % {
          account_id:,
          contract_id:,
          equipment_types: equipment.map { |equipment_entry| equipment_entry.fetch('id').to_i }.join(',')
        }
        db_value = loader(sql, {}).load
        db_value.map do |subscription|
          subscription['allowProvisioning'] = subscription['allowProvisioning'] == CONST::CL_CREATING_ALLOWED
        end
        nest_subscriptions(db_value.as_json)
      end

      # nest child subscriptions into childServices within parent ones
      def nest_subscriptions(subscriptions)
        parent_subscriptions = subscriptions.select do |subscription|
          subscription['parSubscriptionId'].nil?
        end
        parent_subscriptions.each do |subscription|
          subscription['childServices'] = subscriptions.select do |subs|
            subs['parSubscriptionId'] == subscription['subscriptionId']
          end
        end

        parent_subscriptions
      end

      class SourceLoader
        include HBW::Logger

        attr_reader :name, :source, :condition, :variables

        def initialize(name, source, condition, variables)
          @name      = name
          @source    = source
          @condition = condition
          @variables = variables
        end

        def load(limit = nil)
          values = source.select(condition, variables, limit)
          logger.debug do
            "Retrieved values for %s\nfrom source %s\ncondition: %s\nvariables: %s.\nResult: %s" %
              [name, source, condition, variables, values.to_s]
          end
          values
        end
      end

      def coerce(value)
        case data_type
        when :json then value
        else
          fail_unsupported_coercion(value)
        end
      end

      def as_json
        {name:,
         value:,
         type:,
         label:,
         css_class:,
         label_css:,
         nullable:           nullable?,
         editable:           editable?,
         delimiter:          delimiter?,
         delete_if:,
         disable_if:,
         dynamic:,
         variables:,
         current_value:      value,
         customer_id:,
         account_id:,
         contract_id:,
         currency_code:,
         equipment_types:    equipment,
         individual_pricing: individual_pricing?,
         hidden_columns:,
         date_format:,
         disable_search:}
      end

      def loader(condition, variables)
        SourceLoader.new(name, Sources.fetch('billing'), condition, variables)
      end

      def label
        definition.fetch('label', '')
      end

      def date_format
        definition.fetch('date_format', 'DD.MM.YYYY')
      end

      def nullable?
        definition.fetch('nullable', true)
      end

      def get_definition_prop_value(prop_name, default_value = nil, required: true)
        value = definition.fetch(prop_name, nil)
        if value.nil?
          unless required
            return default_value
          end

          raise ArgumentError, '%s is not specified' % prop_name
        end
        value
      end

      def get_variable_value(variable_name)
        variable = variables.find { |v| v['name'] == variable_name }
        if variable.nil?
          raise ArgumentError, '%s variable is not specified' % variable_name
        end

        variable['value']
      end

      def get_bpm_prop_value(prop_name, default_value = nil, required: true)
        variable_name = get_definition_prop_value(prop_name, default_value, required:)
        if variable_name == default_value
          return default_value
        end

        variable_value = get_variable_value(variable_name)

        # Second condition is to make it possible to show all columns ([] for hidden headers variable)
        unless variable_value.present? || (variable_value.instance_of? Array)
          raise ArgumentError, '%s variable is empty' % variable_name
        end

        variable_value
      end

      def account_id
        get_bpm_prop_value('account_id_variable')
      end

      def customer_id
        get_bpm_prop_value('customer_id_variable')
      end

      def contract_id
        get_bpm_prop_value('contract_id_variable')
      end

      # TODO: Add currency symbol fetching with a lib lib for money formatting
      def currency_code
        '$'
      end

      def equipment
        get_bpm_prop_value('equipment_variable')
      end

      def individual_pricing?
        get_bpm_prop_value('individual_pricing_allowed_variable', false, required: false)
      end

      def hidden_columns
        get_bpm_prop_value('hidden_columns_variable', nil, required: false)
      end

      def disable_search
        get_definition_prop_value('disable_search', false, required: false)
      end
    end
  end
end
