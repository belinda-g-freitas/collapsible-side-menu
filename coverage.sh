## ONLY FOR MAC OR LINUX 

# Run test coverage
flutter test --coverage

# Generate coverage info
genhtml -o coverage coverage/lcov.info 

# Open to see coverage info
open coverage/index.html