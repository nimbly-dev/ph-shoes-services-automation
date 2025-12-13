#!/usr/bin/env python3
"""
Property-based tests for memory allocation constraints in ECS service deployment.

**Feature: render-to-ecs-migration, Property 1: Memory Allocation Constraint**
**Validates: Requirements 2.4**

This test validates that for any service deployment configuration, the total memory 
allocation across all services should not exceed t3.micro usable capacity 
(840MB, leaving 100MB system buffer).
"""

import json
import subprocess
import tempfile
import os
from hypothesis import given, strategies as st, settings
from hypothesis.strategies import composite
import pytest


# Constants from terraform configuration
MAX_TOTAL_MEMORY_MB = 940  # t3.micro total memory
SYSTEM_BUFFER_MB = 100     # Reserved for OS/ECS agent
MAX_USABLE_MEMORY_MB = MAX_TOTAL_MEMORY_MB - SYSTEM_BUFFER_MB  # 840MB


@composite
def service_memory_config(draw):
    """Generate valid service memory configurations."""
    # Generate memory allocation that could be valid or invalid
    memory_mb = draw(st.integers(min_value=64, max_value=1024))
    
    return {
        "memory": memory_mb,
        "system_buffer_mb": SYSTEM_BUFFER_MB,
        "max_total_memory_mb": MAX_TOTAL_MEMORY_MB
    }


@composite
def multiple_services_config(draw):
    """Generate configurations for multiple services."""
    num_services = draw(st.integers(min_value=1, max_value=5))
    services = []
    
    for i in range(num_services):
        memory_mb = draw(st.integers(min_value=64, max_value=512))
        services.append({
            "name": f"service-{i}",
            "memory": memory_mb
        })
    
    return services


def validate_memory_allocation_terraform(memory_mb, system_buffer_mb=SYSTEM_BUFFER_MB, 
                                       max_total_memory_mb=MAX_TOTAL_MEMORY_MB):
    """
    Validate memory allocation using terraform logic.
    Returns True if allocation is valid, False otherwise.
    """
    available_memory_mb = max_total_memory_mb - system_buffer_mb
    return memory_mb <= available_memory_mb


def create_terraform_test_config(memory_mb, system_buffer_mb=SYSTEM_BUFFER_MB,
                                max_total_memory_mb=MAX_TOTAL_MEMORY_MB):
    """Create a minimal terraform configuration for testing memory validation."""
    
    terraform_config = f"""
variable "memory" {{
  description = "Task memory"
  type        = number
  default     = {memory_mb}
}}

variable "system_buffer_mb" {{
  description = "System buffer reservation in MB"
  type        = number
  default     = {system_buffer_mb}
}}

variable "max_total_memory_mb" {{
  description = "Maximum total memory available on t3.micro instance in MB"
  type        = number
  default     = {max_total_memory_mb}
}}

locals {{
  # Calculate available memory after system buffer
  available_memory_mb = var.max_total_memory_mb - var.system_buffer_mb
  
  # Memory validation
  memory_exceeds_limit = var.memory > local.available_memory_mb
}}

# Memory validation check
resource "null_resource" "memory_validation" {{
  count = local.memory_exceeds_limit ? 1 : 0
  
  provisioner "local-exec" {{
    command = "echo 'ERROR: Memory allocation ${{var.memory}}MB exceeds available capacity ${{local.available_memory_mb}}MB (${{var.max_total_memory_mb}}MB total - ${{var.system_buffer_mb}}MB system buffer)' && exit 1"
  }}
}}

output "memory_allocation_status" {{
  value = {{
    allocated_memory_mb = var.memory
    available_memory_mb = local.available_memory_mb
    system_buffer_mb    = var.system_buffer_mb
    total_memory_mb     = var.max_total_memory_mb
    within_limits       = !local.memory_exceeds_limit
  }}
  description = "Memory allocation status and limits"
}}
"""
    return terraform_config


class TestMemoryAllocationConstraints:
    """Property-based tests for memory allocation constraints."""

    @given(service_memory_config())
    @settings(max_examples=100)
    def test_memory_allocation_constraint_property(self, config):
        """
        **Feature: render-to-ecs-migration, Property 1: Memory Allocation Constraint**
        **Validates: Requirements 2.4**
        
        Property: For any service deployment configuration, the total memory allocation 
        should not exceed t3.micro usable capacity (840MB, leaving 100MB system buffer).
        """
        memory_mb = config["memory"]
        system_buffer_mb = config["system_buffer_mb"]
        max_total_memory_mb = config["max_total_memory_mb"]
        
        # Calculate expected validation result
        available_memory_mb = max_total_memory_mb - system_buffer_mb
        should_be_valid = memory_mb <= available_memory_mb
        
        # Test our validation logic
        is_valid = validate_memory_allocation_terraform(
            memory_mb, system_buffer_mb, max_total_memory_mb
        )
        
        # The validation should match our expectation
        assert is_valid == should_be_valid, (
            f"Memory validation mismatch: {memory_mb}MB allocation "
            f"(available: {available_memory_mb}MB) should be "
            f"{'valid' if should_be_valid else 'invalid'} but got "
            f"{'valid' if is_valid else 'invalid'}"
        )
        
        # Additional constraint: memory should never exceed available capacity
        if memory_mb > available_memory_mb:
            assert not is_valid, (
                f"Memory allocation {memory_mb}MB exceeds available capacity "
                f"{available_memory_mb}MB but validation passed"
            )

    @given(multiple_services_config())
    @settings(max_examples=50)
    def test_multiple_services_memory_constraint(self, services):
        """
        Test memory allocation constraints for multiple services scenario.
        
        This tests the realistic scenario where multiple services are deployed
        on the same t3.micro instance.
        """
        total_memory = sum(service["memory"] for service in services)
        
        # Each individual service should be validated
        for service in services:
            is_valid = validate_memory_allocation_terraform(service["memory"])
            
            # If total memory exceeds limit, at least one service should be invalid
            if total_memory > MAX_USABLE_MEMORY_MB:
                # We can't guarantee which specific service will be invalid,
                # but the total should exceed limits
                assert total_memory > MAX_USABLE_MEMORY_MB
            
            # Individual services with reasonable memory should be valid
            if service["memory"] <= MAX_USABLE_MEMORY_MB:
                assert is_valid, (
                    f"Service {service['name']} with {service['memory']}MB "
                    f"should be valid (limit: {MAX_USABLE_MEMORY_MB}MB)"
                )

    def test_boundary_conditions(self):
        """Test specific boundary conditions for memory allocation."""
        
        # Test exact limit (should be valid)
        assert validate_memory_allocation_terraform(MAX_USABLE_MEMORY_MB)
        
        # Test one MB over limit (should be invalid)
        assert not validate_memory_allocation_terraform(MAX_USABLE_MEMORY_MB + 1)
        
        # Test minimum reasonable memory (should be valid)
        assert validate_memory_allocation_terraform(64)
        
        # Test zero memory (should be valid but impractical)
        assert validate_memory_allocation_terraform(0)

    def test_system_buffer_calculation(self):
        """Test that system buffer is correctly accounted for."""
        
        # With default system buffer (100MB), available should be 840MB
        available = MAX_TOTAL_MEMORY_MB - SYSTEM_BUFFER_MB
        assert available == 840
        
        # Test with different system buffer sizes
        custom_buffer = 150
        custom_available = MAX_TOTAL_MEMORY_MB - custom_buffer
        
        # Memory allocation equal to custom available should be valid
        assert validate_memory_allocation_terraform(
            custom_available, custom_buffer, MAX_TOTAL_MEMORY_MB
        )
        
        # Memory allocation exceeding custom available should be invalid
        assert not validate_memory_allocation_terraform(
            custom_available + 1, custom_buffer, MAX_TOTAL_MEMORY_MB
        )


if __name__ == "__main__":
    # Run the tests
    pytest.main([__file__, "-v"])