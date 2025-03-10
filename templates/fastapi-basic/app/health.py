from fastapi import APIRouter, status
from typing import Dict

router = APIRouter(
    prefix="/health",
    tags=["system"],
    responses={404: {"description": "Not found"}},
)

@router.get("",
    response_model=Dict[str, str],
    summary="Health check endpoint",
    description="Checks if the application is running properly",
    status_code=status.HTTP_200_OK,
    responses={
        200: {
            "description": "Application is healthy",
            "content": {
                "application/json": {
                    "example": {"status": "healthy"}
                }
            }
        },
        503: {
            "description": "Application is unhealthy",
            "content": {
                "application/json": {
                    "example": {"status": "unhealthy", "details": "Service unavailable"}
                }
            }
        }
    }
)
async def health_check() -> Dict[str, str]:
    """
    Performs a health check of the application.
    
    Returns:
        Dict[str, str]: A dictionary containing the health status
    """
    return {"status": "healthy"} 