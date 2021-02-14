module Inference = {
  let fetchCats = () =>
    Axios.get("someapi.com/cats")
    |> Js.Promise.then_(response => Js.Promise.resolve(response["data"]))
    |> Js.Promise.then_(data => {
      data["cats"]->Belt.Array.forEach(cat => {
        Js.log(cat["name"])
        Js.log(cat["age"])
      })
      Js.Promise.resolve()
    })
}

module ManualConversion = {
  type cat = {age: int, name: string}
  let fromJs = catApiPayload => {
    name: catApiPayload["name"],
    age: catApiPayload["age"],
  }

  let fetchCats = () =>
    Axios.get("someapi.com/cats")
    |> Js.Promise.then_(response => Js.Promise.resolve(response["data"]))
    |> Js.Promise.then_(data => {
      let cats = data["cats"]->Belt.Array.map(cat => fromJs(cat))
      Js.Promise.resolve(cats)
    })

  fetchCats()
  |> Js.Promise.then_(cats => {
    cats->Belt.Array.forEach(cat => {
      Js.log(cat.name)
    })
    Js.Promise.resolve()
  })
  |> ignore
}

module BsJsonConversion = {
  type cat = {age: int, name: string}

  module Decode = {
    let cat = json => {
      open Json.Decode
      {
        name: json |> field("name", string),
        age: json |> field("age", int),
      }
    }
  }

  let fetchCats = () =>
    Axios.get("someapi.com/cats")
    |> Js.Promise.then_(response => Js.Promise.resolve(response["data"]))
    |> Js.Promise.then_(data => {
      let decodedCats = data["cats"]->Belt.Array.map(cat => cat |> Json.parseOrRaise |> Decode.cat)

      Js.Promise.resolve(decodedCats)
    })

  fetchCats()
  |> Js.Promise.then_(cats => {
    cats->Belt.Array.forEach(cat => {
      Js.log(cat.name)
    })
    Js.Promise.resolve()
  })
  |> ignore
}

module DeccoConversion = {
  @decco
  type cat = {
    age: int,
    name: string,
  }

  @decco
  type apiResponse = array<cat>

  let fetchCats = () =>
    Axios.get("someapi.com/cats")
    |> Js.Promise.then_(response => Js.Promise.resolve(response["data"]))
    |> Js.Promise.then_(data => apiResponse_decode->data->Js.Promise.resolve)
    |> Js.Promise.then_(result => {
      switch result {
      | Ok(cats) => Js.Promise.resolve(cats)
      | Error(err) => {
          Js.log(err) // Will print a message explaining where there is a missmatch
          Js.Promise.reject(err)
        }
      }
    })

  fetchCats()
  |> Js.Promise.then_(cats => {
    cats->Belt.Array.forEach(cat => {
      Js.log(cat.name)
    })
    Js.Promise.resolve()
  })
  |> ignore
}
