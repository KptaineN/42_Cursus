#g++ -std=c++98 -Wall -Wextra -Werror megaphone.cpp -o main

# ========== Configuration ==========
NAME        = 
SRC_DIR     = 
BUILD_DIR   = 
CPP         = 
FLAGS       = -Wall -Wextra -Werror
VERSION     = 
RUN         = ./

# Liste des fichiers sources
SRCS        = $(wildcard $(SRC_DIR)/*.cpp)
# Liste des objets (dans BUILD_DIR)
OBJECTS     = $(patsubst $(SRC_DIR)/%.cpp, $(BUILD_DIR)/%.o, $(SRCS))

# ========== Règles ==========
all: $(NAME)

# Règle de liaison : crée l'exécutable à la racine
$(NAME): $(OBJECTS)
	$(CPP) $(VERSION) $(FLAGS) $^ -o $@

# Règle de compilation : génère les objets dans BUILD_DIR
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(BUILD_DIR)
	$(CPP) $(VERSION) $(FLAGS) -c $< -o $@

# Nettoyage des objets
clean:
	-rm -rf $(BUILD_DIR)/*.o

# Nettoyage complet (objets + exécutable)
fclean: clean
	-rm -f $(NAME)

# Recompilation complète
re: fclean all

# Exécution du programme
run: all
	$(RUN)$(NAME)

# ========== Cibles PHONY ==========
.PHONY: all clean fclean re run

