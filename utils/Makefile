DEBUG		= -O3
CXX			= g++
CCFLAGS		= $(DEBUG)
CPPFLAGS	= -I. -o $(@)
LDFLAGS		= 

DINF_SRC= \
	diskinfo.cpp \
	fatdisk.cpp

DECB_SRC= \
	decbinfo.cpp

DINF_OBJ=$(DINF_SRC:.cpp=.o)
DECB_OBJ=$(DECB_SRC:.cpp=.o)

all: diskinfo decbinfo

decbinfo: $(DECB_OBJ)
	$(CXX) $(CCFLAGS) $(LDFLAGS) $(DECB_OBJ) -o $(@)

diskinfo:	$(DINF_OBJ)
	$(CXX) $(CCFLAGS) $(LDFLAGS) $(DINF_OBJ) -o $(@)

.SUFFIXES: .cpp

.cpp.o:
	$(CXX) $(CPPFLAGS) $(CCFLAGS) -c $<

clean:
	$(RM) dislkinfo $(BIN) $(DECB_OBJ) $(DINF_OBJ)

fatdisk.cpp:	fatdisk.h

*.o:	diskinfo.h

