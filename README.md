# fig_database_linker(数据库连接器)

named FIG database objecter linker,it suport:

名为fig的数据库对象化连接工具,支持:

- MySQL
- SQLite
- PostgreSQL

> 敬请期待

同时支持数据类型:
- int
- string
- float
- date
- decimal

> 敬请等待

## Getting Started

如果想知道如何使用,可以查看simple文件,若仍然不明白,请到github或微信或邮箱中提问,如果你希望它变得更优秀,请在github中提交建议的代码,我承诺如果此包产生利益,将会回报你的付出.

## 它是怎样运作的?

它是依靠类的多态来抽象数据库连接,内中的抽象类都含有abs字元,当你使用它时,你将不需要了解它到底是哪个数据库,只需抽象地使用它就够了,抽象化可以让你日后的代码移植能够更轻松.
