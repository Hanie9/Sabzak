import random, string

def create_session():
    length = 50
    chars = string.ascii_letters + string.digits
    return ''.join(random.choice(chars) for i in range(length))