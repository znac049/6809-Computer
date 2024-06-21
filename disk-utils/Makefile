DEBUG		= -O3
CXX			= g++
CCFLAGS		= $(DEBUG)
CPPFLAGS	= -I. -o $(@)
LDFLAGS		= 

SRCS		= diskinfo.cpp \
			fatdisk.cpp

OBJS		= $(SRCS:.cpp=.o)

all: diskinfo

diskinfo:	$(OBJS)
	$(CXX) $(CCFLAGS) $(LDFLAGS) $(OBJS) -o $(@)

.SUFFIXES: .cpp

.cpp.o:
	$(CXX) $(CPPFLAGS) $(CCFLAGS) -c $<

clean:
	$(RM) dislkinfo $(BIN) $(OBJS)

fatdisk.cpp:	fatdisk.h

*.o:	diskinfo.h

