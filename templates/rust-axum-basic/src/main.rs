use axum::{
    routing::{get, Router},
    Json,
};
use serde::Serialize;
use std::net::SocketAddr;
use tower_http::trace::TraceLayer;
use utoipa::{OpenApi, ToSchema};
use utoipa_swagger_ui::SwaggerUi;

mod health;
use health::HealthResponse;

#[derive(OpenApi)]
#[openapi(
    paths(
        health::health_check,
        root
    ),
    components(
        schemas(HealthResponse, RootResponse)
    ),
    tags(
        (name = "{{display_name}}", description = "{{display_name}} API endpoints")
    )
)]
struct ApiDoc;

#[derive(Serialize, ToSchema)]
struct RootResponse {
    message: String,
}

/// Root endpoint handler
#[utoipa::path(
    get,
    path = "/",
    tag = "{{display_name}}",
    responses(
        (status = 200, description = "Welcome message", body = RootResponse)
    )
)]
async fn root() -> Json<RootResponse> {
    Json(RootResponse {
        message: "Welcome to {{display_name}}".to_string(),
    })
}

#[tokio::main]
async fn main() {
    // Initialize tracing
    tracing_subscriber::fmt()
        .with_target(false)
        .compact()
        .init();

    // Build OpenAPI documentation
    let api_doc = ApiDoc::openapi();

    // Create router with all routes
    let app = Router::new()
        .merge(SwaggerUi::new("/docs").url("/api-docs/openapi.json", api_doc))
        .route("/", get(root))
        .nest("/health", health::router())
        .layer(TraceLayer::new_for_http());

    // Run the server
    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    println!("Server running on http://{}", addr);
    println!("API documentation available at http://{}/docs", addr);

    axum::serve(
        tokio::net::TcpListener::bind(addr).await.unwrap(),
        app.into_make_service(),
    )
    .await
    .unwrap();
} 