extern crate reqwest;
extern crate serde_json;

use std::env;

use reqwest::blocking::{Client, Response};
use reqwest::header::{HeaderMap, HeaderValue, CONTENT_TYPE, USER_AGENT};
use reqwest::Error;

use serde_json::{json, value::Value};

const BASE_URL: &str = "https://discord.com/api/v8";

fn get_headers() -> HeaderMap {
    let mut headers = HeaderMap::new();
    headers.insert(USER_AGENT, HeaderValue::from_static("hype"));
    headers.insert(
        CONTENT_TYPE,
        HeaderValue::from_static("application/x-www-form-urlencoded"),
    );
    headers
}

fn get_data() -> Value {
    json!({
        "grant_type": "client_credentials",
        "scope": "identify connections",
    })
}

fn get_token(user: &str, pass: &str) -> Result<Response, Error> {
    let url = format!("{}/oauth2/token", BASE_URL);
    let headers = get_headers();
    let data = get_data();

    let body =
        serde_urlencoded::to_string(&data).expect("unexpected data is given");

    let client = Client::new();
    client
        .post(&url)
        .basic_auth(user, Some(pass))
        .headers(headers)
        .body(body)
        .send()
}

fn main() {
    let user = env::var("CLIENT_ID").expect("CLIENT_ID is not set");
    let pass = env::var("CLIENT_SECRET").expect("CLIENT_SECRET is not set");

    let result = get_token(&user, &pass);
    let res = result.unwrap();

    // TODO
    println!("response = {:?}", res.text());
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_get_headers() {
        let headers: HeaderMap = get_headers();

        assert_eq!(headers.get(USER_AGENT).unwrap(), &"hype");
        assert_eq!(
            headers.get(CONTENT_TYPE).unwrap(),
            &"application/x-www-form-urlencoded"
        );
    }

    #[test]
    fn test_get_data() {
        let data: Value = get_data();

        assert_eq!(
            *data.get("grant_type").unwrap(),
            json!("client_credentials")
        );
        assert_eq!(*data.get("scope").unwrap(), json!("identify connections"));
    }
}
