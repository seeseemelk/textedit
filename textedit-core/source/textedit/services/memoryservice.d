module textedit.services.memoryservice;

import core.memory;

/** 
 * A service to retrieve memory information.
 */
interface IMemoryService
{
	size_t usedMemory() const;
	size_t freeMemory() const;
	size_t totalMemory() const;
}

class MemoryService : IMemoryService
{
	override size_t usedMemory() const
	{
		return GC.stats.usedSize;
	}

	@("usedMemory must be > 0")
	unittest
	{
		auto service = new MemoryService();
		assert(service.usedMemory > 0);
	}

	override size_t freeMemory() const
	{
		return GC.stats.freeSize;
	}

	@("freeMemory must be > 0")
	unittest
	{
		auto service = new MemoryService();
		assert(service.freeMemory > 0);
	}

	override size_t totalMemory() const
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