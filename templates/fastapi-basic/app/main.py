from fastapi import FastAPI
from typing import Dict
from app.health import router as health_router

app = FastAPI(
    title="{{display_name}}",
    description="A FastAPI project created from basic template",
    version="0.1.0",
    contact={
        "name": "Your Name",
        "url": "https://github.com/yourusername/{{display_name}}",
        "email": "your.email@example.com",
    },
    license_info={
        "name": "MIT",
        "url": "https://opensource.org/licenses/MIT",
    }
)

@app.get("/",
    response_model=Dict[str, str],
    summary="Root endpoint",
    description="Returns a friendly greeting message",
    tags=["general"]
)
async def read_root() -> Dict[str, str]:
    """
    Root endpoint that returns a greeting message.
    
    Returns:
        Dict[str, str]: A dictionary containing a welcome message
    """
    return {"message": "Hello World"}

# Include routers
app.include_router(health_router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 