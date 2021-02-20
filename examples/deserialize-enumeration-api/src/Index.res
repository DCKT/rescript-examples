module CatBreed = {
  @deriving(jsConverter)
  type breed = [
    | #aegean
    | #abyssinian
    | #balinese
    | #bambino
    | #bengal
  ]

  let encoder: Decco.encoder<brand> = (brand: brand) => {
    brand->brandToJs->Decco.stringToJson
  }

  let decoder: Decco.decoder<brand> = json => {
    switch json->Decco.stringFromJson {
    | Belt.Result.Ok(v) =>
      switch v->brandFromJs {
      | None => Decco.error(~path="", "Invalid enum " ++ v, json)
      | Some(v) => v->Ok
      }
    | Belt.Result.Error(_) as err => err
    }
  }

  let codec: Decco.codec<brand> = (encoder, decoder)

  @decco
  type t = @decco.codec(codec) brand
}

@decco
type cat = {
  age: int,
  name: string,
  breed: CatBreed.t,
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
