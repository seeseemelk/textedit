module textedit.services.memoryservice;

import core.memory;

class MemoryService
{
	size_t usedMemory()
	{
		return GC.stats.usedSize;
	}

	@("usedMemory must be > 0")
	unittest
	{
		auto service = new MemoryService();
		assert(service.usedMemory > 0);
	}

	size_t freeMemory()
	{
		return GC.stats.freeSize;
	}

	@("freeMemory must be > 0")
	unittest
	{
		auto service = new MemoryService();
		assert(service.freeMemory > 0);
	}

	size_t totalMemory()
	{
		return usedMemory() + freeMemory();
	}

	@("totalMemory must be > 0")
	unittest
	{
		auto service = new MemoryService();
		assert(service.totalMemory > 0);
	}
}