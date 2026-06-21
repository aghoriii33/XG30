import os
# pyrefly: ignore [missing-import]
from pydantic_settings import BaseSettings
# pyrefly: ignore [missing-import]
from dotenv import load_dotenv

# Find and load the root env file if it exists
root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
env_path = os.path.join(root_dir, ".env")
if os.path.exists(env_path):
    load_dotenv(env_path)

class Settings(BaseSettings):
    OPENAI_API_KEY: str = "mock"
    STRIPE_API_KEY: str = "mock"
    STRIPE_WEBHOOK_SECRET: str = "mock"
    FIREBASE_CREDENTIALS_PATH: str = ""
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    @property
    def is_openai_mock(self) -> bool:
        return not self.OPENAI_API_KEY or self.OPENAI_API_KEY == "mock" or "YOUR_API_KEY" in self.OPENAI_API_KEY

    @property
    def is_stripe_mock(self) -> bool:
        return not self.STRIPE_API_KEY or self.STRIPE_API_KEY == "mock"

    @property
    def is_firebase_mock(self) -> bool:
        return not self.FIREBASE_CREDENTIALS_PATH or not os.path.exists(self.FIREBASE_CREDENTIALS_PATH)

settings = Settings()
