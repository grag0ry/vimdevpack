GIT = git

.PHONY: sm
sm:
	$(GIT) submodule update --init --recursive 
