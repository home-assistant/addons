/*
 *  Copyright (c) 2024, The OpenThread Authors.
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  3. Neither the name of the copyright holder nor the
 *     names of its contributors may be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 *  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *  POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef OPENTHREAD_CORE_HA_CONFIG_POSIX_H_
#define OPENTHREAD_CORE_HA_CONFIG_POSIX_H_

/**
 * This header file defines the OpenThread core configuration options for
 * Home Assistant with POSIX platform.
 */

/**
 * It seems that routes learned through IPv6 Neighbor Discovery Protocol
 * get a metric of 128 when NetworkManager is used. Make sure the
 * OpenThread network interface's own route is lower than that, to ensure
 * that the local radio is preferred over learned routes.
 */
#define OPENTHREAD_POSIX_CONFIG_NETIF_PREFIX_ROUTE_METRIC 64

/**
 * Increase delay aware queue management entry list size from its default of
 * 16 to 64. This is to avoid/decrease the number of "Failed to get forwarded
 * frame priority" notice messages.
 */
#define OPENTHREAD_CONFIG_DELAY_AWARE_QUEUE_MANAGEMENT_FRAG_TAG_ENTRY_LIST_SIZE 64

/**
 * The impact on production systems is not entirly clear. The channel scan could lead to
 * missed packets. Disabling by default allows to enable the feature at compile time so
 * developers and users can enable it at runtime for testing.
 */
#define OPENTHREAD_CONFIG_CHANNEL_MONITOR_AUTO_START_ENABLE 0

#endif /* OPENTHREAD_CORE_HA_CONFIG_POSIX_H_ */
