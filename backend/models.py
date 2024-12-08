from typing import Optional
from pydantic import BaseModel

class Plant(BaseModel):
    plantid: int
    plantName: str
    price: int
    size: str
    rating: float
    humidity: int
    temperature: str
    category: str
    isfavorite: bool
    description: Optional[str] = None


class SignUp(BaseModel):
    firstName: str
    lastName: str
    password: str
    username: str
    email: str
    

class Login(BaseModel):
    password: str
    username: Optional[str] = None
    email: Optional[str] = None

class CartProducts(BaseModel):
    productId: int
    quantity: int


class AddtoCart(BaseModel):
    userId: int
    product: CartProducts


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

    

class CustomerModel(BaseModel):
    firstName: str
    lastName: str
    email: str
    password: str
    username: str

class CartItem(BaseModel):
    plant: Plant
    quantity: int
    

class Cart(BaseModel):
    items: list[CartItem] = []