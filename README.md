# fig_database_linker

[中文版>>](/README_CN.md)

named FIG database objecter linker,it suport:
- MySQL
- SQLite
- PostgreSQL

it suport:
- int
- string
- float
- date
- decimal

## Getting Started

If you want to know how to use it, you can check the simple file. If you still don’t understand, please go to github or WeChat or email to ask questions. If you want it to be better, please submit the suggested code in github. I promise that if this package is produced Benefits will repay your efforts.

## How does it work?

It relies on the polymorphism of the class to abstract the database connection. The abstract classes in it all contain the abs character. When you use it, you don't need to know which database it is, just use it abstractly. Abstraction can make your future code porting easier.
