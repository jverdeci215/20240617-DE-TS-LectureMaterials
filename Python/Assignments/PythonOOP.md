#   Python OOP Assignment: Computer Modeling 

 

##  Scenario Overview 

In this assignment, you will be creating a Python model for a computer system. This model will represent various components of a computer, such as the CPU, memory, and storage. You will use Object-Oriented Programming (OOP) principles to design and implement this model, showcasing your understanding of key OOP concepts like classes, inheritance, encapsulation, and polymorphism. 

 

##  Problem Statement 

Your task is to design a Python program that can represent different types of computers. Each computer should be composed of different components, and each component should have its own characteristics and functionalities. The goal is to create a flexible and scalable model that can easily be expanded or modified to represent various types of computer systems. 

 

##  Assignment Tasks 

 

1. Basic Computer Components 

    - Create a base class named `ComputerComponent` which will act as a superclass for different computer parts. 
    - Define common attributes (like `manufacturer`, `model`, `serial_number`) in the `ComputerComponent` class. 
    - Implement a method in `ComputerComponent` to display details about the component. 

 

2. Specific Component Classes 

    - Create subclasses of `ComputerComponent` for different components: `CPU`, `Memory`, `Storage`. 
    - Each subclass should have specific attributes relevant to the component type. For instance, `CPU` might have `cores` and `clock_speed`, `Memory` could have `capacity`, and `Storage` might include `storage_type` and `size`. 

 

3. Computer Class 

    - Create a `Computer` class that uses these components. 
    - The `Computer` class should have attributes to hold instances of `CPU`, `Memory`, and `Storage`. 
    - Implement a method in the `Computer` class to display information about the entire computer, including its components. 

 

4. Advanced Features 

    - Implement error checking in the `Computer` class to ensure that only appropriate components (instances of `ComputerComponent` subclasses) are associated with the computer. 
    - Implement a method that allows a user to replace a component with a different one of the same type. 
    - Use polymorphism to allow different types of CPUs, Memories, and Storages to be used interchangeably in the `Computer` class. 