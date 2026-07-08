NAME = ircserv

CXX = c++
CXXFLAGS = -Wall -Wextra -Werror -std=c++98 -Iincludes

SRCS = src/main.cpp     \

# src/debug.cpp       
OBJS = $(SRCS:.cpp=.o)


# Default target: build release (no debug)
all: release

# Release: compile without DEBUG
release:
	$(CXX) $(CXXFLAGS) $(SRCS) -o $(NAME)

# Debug: compile with DEBUG enabled
debug:
	$(CXX) $(CXXFLAGS) -DDEBUG=1 $(SRCS) -o $(NAME)

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
