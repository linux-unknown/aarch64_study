/*
 * boot.S - simple register setup code for stand-alone Linux booting
 *
 * Copyright (C) 2012 ARM Limited. All rights reserved.
 *
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE.txt file.
 */

#include "common.S"

	.text

	.globl	_start
_start:
	/*
	 * EL3 initialisation
	 */
	mrs	x0, CurrentEL	/*读取当前的异常级别Current Exception Level*/
	cmp	x0, #CURRENTEL_EL3     /*进行比较*/
	b.ne	start_no_el3			// skip EL3 initialisation，如果不是EL3，则跳转到start_no_el3，定义在psci.S

	/*如果为el3*/
	mov	x0, #0x30			// RES1
	orr	x0, x0, #(1 << 0)		// Non-secure EL1  EL0和EL1为Non-secure
	orr	x0, x0, #(1 << 8)		// HVC enable   Enables HVC instructions at EL3, EL2, and Non-secure EL1
	orr	x0, x0, #(1 << 10)		// 64-bit EL2	低异常级别为aarch64
	msr	scr_el3, x0

	msr	cptr_el3, xzr			// Disable copro. traps to EL3 禁止陷入EL3

	ldr	x0, =CNTFRQ
	msr	cntfrq_el0, x0 /*系统conter的时钟*/

	bl	gic_secure_init

	b	start_el3

	.ltorg

	.org	0x100
