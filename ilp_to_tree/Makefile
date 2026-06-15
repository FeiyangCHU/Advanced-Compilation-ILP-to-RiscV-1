# source directory
SRC_DIR := Java/src/com/paracamplus/ilp[12]

# grammar generated sources
ANTLR_DIR := ANTLRGrammars/

# grammar generated sources
SRC_GEN_DIR := target/generated-sources/antlr4

#jars
JAR_DIR := Java/jars

# antlr jar
ANTLRJAR := $(JAR_DIR)/antlr-4.4-complete.jar
JINGJAR := $(JAR_DIR)/jing.jar
TRANGJAR := $(JAR_DIR)/trang.jar
OPENTEST := $(JAR_DIR)/opentest4j-1.3.0.jar
APIGUARD := $(JAR_DIR)/apiguardian-api-1.1.2.jar
JUNIT_API     := $(JAR_DIR)/junit-jupiter-api-5.10.2.jar
JUNIT_ENGINE  := $(JAR_DIR)/junit-jupiter-engine-5.10.2.jar
JUNIT_PARAMS  := $(JAR_DIR)/junit-jupiter-params-5.10.2.jar
JUNIT_API := $(JAR_DIR)/junit-jupiter-api-5.10.2.jar
JUNIT_ENGINE := $(JAR_DIR)/junit-jupiter-engine-5.10.2.jar
PLATFORM_SUITE := $(JAR_DIR)/junit-platform-suite-api-1.10.2.jar
PLATFORM_COMMONS := $(JAR_DIR)/junit-platform-commons-1.10.2.jar
PLATFORM_LAUNCHER := $(JAR_DIR)/junit-platform-launcher-1.10.2.jar
OPENTEST := $(JAR_DIR)/opentest4j-1.3.0.jar
APIGUARD := $(JAR_DIR)/apiguardian-api-1.1.2.jar

# output directory
OUT_DIR := out

# recursive wildcard
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2)\
	$(filter $(subst *,%,$2),$d))

# sources
SRCS := $(call rwildcard,$(SRC_DIR),*.java)

# classes
CLS := $(SRCS:.java=.class)

# compiler and compiler flags
JC := javac
CP := $(ANTLRJAR):$(JINGJAR):$(JUNIT_API):$(JUNIT_ENGINE):$(OPENTEST):$(APIGUARD):$(TRANGJAR):$(JUNIT_API):$(JUNIT_ENGINE):$(JUNIT_PARAMS):$(PLATFORM_SUITE):$(PLATFORM_COMMONS):$(PLATFORM_LAUNCHER):$(SRC_DIR)/:$(SRC_GEN_DIR)/
JCFLAGS := -d $(OUT_DIR)/ -cp $(CP)

.PHONY: clean

# default target(s)
all: antlr srcs

test: antlr srcs
	./ja.sh --check Samples

srcs:
	$(JC) $(JCFLAGS) $(SRCS)

antlr:
	./compile_ANTLR.sh

# clean up any output files
clean:
	rm -rf $(OUT_DIR)/*
	rm -f $(SRC_GEN_DIR)/*.java
	rm -f $(SRC_GEN_DIR)/*.tokens
	rm -f $(SRC_GEN_DIR)/*.interp
	rm -f Samples/*.resolved
