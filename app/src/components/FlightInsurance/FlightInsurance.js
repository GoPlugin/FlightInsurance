import { useState, useContext, useEffect } from 'react';
import { executeTxn } from '../../service/service';
import { EthereumContext } from "../../eth/context";
import { convertPriceToEth } from "../../eth/transaction";
import './FlightInsurance.css';
import { log } from '../../service/service'

function FlightInsurance() {
  useEffect(async () => {
    await subscribe();
  })

  const [submitting, setSubmitting] = useState(false);
  const { provider, flight } = useContext(EthereumContext);
  console.log("flight", flight)

  const registerFlights = async (event) => {
    event.preventDefault();
    setSubmitting(true);
    let _flightAddress = "0xsdgasdgadsgsdgsdgdsgsdg";
    let _careerFlightNo = "ING695";
    let _serviceProviderName = "Indigo Airlines";
    let response1 = await executeTxn(flight, provider, 'registerFlights', [_flightAddress, _careerFlightNo, _serviceProviderName]);
    log("registerFlights", "hash", response1.txHash)
    setSubmitting(false);
  }

  const bookInsurance = async (event) => {
    event.preventDefault();
    setSubmitting(true);
    let _passengerAddress = "0xsdgasdgadsgsdgsdgdsgsdg";
    let _carrierFlightNumber = "ING695";
    let _departureOn = "Indigo Airlines";
    let _arrivalOn = "Indigo Airlines";
    let _travelday = "Indigo Airlines";

    let response1 = await executeTxn(flight, provider, 'bookInsurance', [_passengerAddress, _carrierFlightNumber, _departureOn, _arrivalOn, _travelday]);
    log("bookInsurance", "hash", response1.txHash)
    setSubmitting(false);
  }


  const submitClaim = async (event) => {
    event.preventDefault();
    setSubmitting(true);
    let _policyId = "1";
    let _jobid = "ING695";
    let _oracleAddress = "Indigo Airlines";

    let response1 = await executeTxn(flight, provider, 'submitClaim', [_policyId, _jobid, _oracleAddress]);
    log("submitClaim", "hash", response1.txHash)
    setSubmitting(false);
  }


  return <div className="Container">
    <div>
      <h1>Register Flights</h1><br></br>
      <form onSubmit={registerFlights}>
        <button type="submit" disabled={submitting}>{submitting ? 'Registering..' : 'Register Flights'}</button>
      </form>
    </div>
    <div></div>
    <div>
      <h1>Book Insurance</h1><br></br>
      <form onSubmit={bookInsurance}>
        <button type="submit" disabled={submitting}>{submitting ? 'Booking..' : 'Book Insurance'}</button>
      </form>
    </div>
    <div>
      <h1>Submit Claims</h1><br></br>
      <form onSubmit={submitClaim}>
        <button type="submit" disabled={submitting}>{submitting ? 'Claiming..' : 'Submit Claims '}</button>
      </form>
    </div>
  </div>
}



export default FlightInsurance;