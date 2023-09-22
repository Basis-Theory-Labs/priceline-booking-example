const axios = require('axios');
const querystring = require('querystring');
const {
  ReactorRuntimeError,
} = require('@basis-theory/basis-theory-reactor-formulas-sdk-js');

module.exports = async function (req) {
  try {
    console.info('Reactor request received.');
    const {
      args: { cardToken, bookRequest },
      configuration: {
        MARQETA_APPLICATION_TOKEN,
        MARQETA_ACCESS_TOKEN,
        PRICELINE_REF_ID,
        PRICELINE_API_KEY,
      },
    } = req;

    const MARQETA_URL = `https://sandbox-api.marqeta.com/v3/cards/${cardToken}/showpan?show_cvv_number=true`;

    const {
      data: { pan, expiration, cvv_number, ...restCardInfo },
    } = await axios.get(MARQETA_URL, {
      auth: {
        username: MARQETA_APPLICATION_TOKEN,
        password: MARQETA_ACCESS_TOKEN,
      },
    });

    console.info('Marqeta card info received.');
    console.info(restCardInfo);

    const PRICELINE_URL =
      'https://api-sandbox.rezserver.com/api/air/getFlightBook';

    const { data } = await axios.post(
      PRICELINE_URL,
      querystring.stringify({
        refid: PRICELINE_REF_ID,
        api_key: PRICELINE_API_KEY,
        cc_number: pan,
        cc_code: cvv_number,
        cc_exp_mo: expiration.slice(0, 2),
        cc_exp_yr: `20${expiration.slice(2)}`,
        format: 'json2',
        ...bookRequest,
      }),
    );

    return {
      raw: {
        data,
      },
    };
  } catch (error) {
    console.error(error); // when connected with the CLI
    throw new ReactorRuntimeError(error);
  }
};
