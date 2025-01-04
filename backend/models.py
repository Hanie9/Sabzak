from typing import Optional
from pydantic import BaseModel

class Plant(BaseModel):
    plantName: str
    price: int
    size: str
    humidity: int
    temperature: str
    category: str
    isfavorite: bool
    description: Optional[str] = None

class Categories(BaseModel):
    name: str

class Address(BaseModel):
    reciever_first_name: str
    reciever_last_name: str
    street: str
    city: str
    neighborhood: Optional[str] = None
    houseNumber: str
    alley: Optional[str] = None
    zipCode: str
    vahed: Optional[str] = None


class Rating(BaseModel):
    plant_id: int
    rating: float
    reaction: str


class SignUp(BaseModel):
    firstName: str
    lastName: str
    password: str
    username: str
    email: str

class Notification(BaseModel):
    notification_title: str
    notification: str
    

class Login(BaseModel):
    password: str
    username: Optional[str] = None
    email: Optional[str] = None


class Billing(BaseModel):
    firstName: str
    lastName: str
    address1: str
    address2: str
    city: str
    postcode: str
    country: str
    email: str
    phone: str


class Shipping(BaseModel):
    firstName: str
    lastName: str
    address1: str
    address2: str
    city: str
    postcode: str
    country: str
    phone: str


class CustomerDetails(BaseModel):
    id: int
    firstName: str
    lastName: str
    email: str
    avatarURL: str
    billing: Billing
    shipping: Shipping


class LineItems(BaseModel):
    productId: int
    quantity: int
    variationId: int


class OrderModel(BaseModel):
    customerId: int
    paymentMethod: str
    paymentMethodTitle: str
    setPaid: bool
    transactionId: str
    lineItems: list[LineItems]
    orderId: int
    orderNumber: str
    status: str
    orderDate: str
    shipping: Shipping
    billing: Billing