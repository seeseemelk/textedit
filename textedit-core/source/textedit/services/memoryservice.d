module textedit.services.memoryservice;

import core.memory;

/** 
 * A service to retrieve memory information.
 */
interface IMemoryService
{
	size_t usedMemory();
	size_t freeMemory();
	size_t totalMemory();
}

class MemoryService : IMemoryService
{
	override size_t usedMemory()
	{
		return GC.stats.usedSize;
	}

	@("usedMemory must be > 0")
	unittest
	{
		auto service = new MemoryService();
		assert(service.usedMemory > 0);
	}

	override size_t freeMemory()
	{
		return GC.stats.freeSize;
	}

	@("freeMemory must be > 0")
	unittest
	{
		auto service = new MemoryService();
		assert(service.freeMemory > 0);
	}

	override size_t totalMemory()
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